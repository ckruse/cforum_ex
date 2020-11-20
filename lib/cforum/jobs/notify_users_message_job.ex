defmodule Cforum.Jobs.NotifyUsersMessageJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import CforumWeb.Gettext

  alias Cforum.Users
  alias Cforum.Messages.Message
  alias Cforum.Messages.MessageHelpers
  alias Cforum.Subscriptions
  alias Cforum.Settings
  alias Cforum.Notifications
  alias CforumWeb.Views.ViewHelpers.Path

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"thread_id" => tid, "message_id" => mid, "type" => type}}) do
    thread = Cforum.Threads.get_thread!(tid)
    message = Cforum.Messages.get_message_from_mid!(thread, mid)

    thread = Cforum.Repo.preload(thread, [:forum])

    broadcast(thread, message)

    users =
      (message.flags["mentions"] || [])
      |> Enum.reject(fn [_, _, in_quote] -> in_quote end)
      |> Enum.uniq_by(fn [_, id, _] -> id end)
      |> Enum.map(fn [_, id, _] -> Users.get_user(id) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.reject(fn user -> user.user_id == message.user_id end)
      |> Enum.filter(&may_view?(&1, thread, message))

    Enum.each(users, fn user -> notify_user_mention(user, thread, message) end)

    if type == "thread" do
      Users.list_users_by_config_option("notify_on_new_thread", "yes")
      |> Enum.reject(fn user -> user.user_id == message.user_id end)
      |> Enum.filter(fn user -> may_view?(user, thread, message) end)
      |> Enum.each(fn user -> notify_user_thread(user, thread, message) end)
    else
      notify_users(thread, message, users)
    end

    :ok
  end

  defp broadcast(thread, message) do
    CforumWeb.Endpoint.broadcast!("forum:#{message.forum_id}", "new_message", %{
      thread: thread,
      message: message,
      forum: Cforum.Forums.get_forum!(message.forum_id)
    })
  end

  defp notify_users(thread, message, already_notified) do
    thread
    |> Cforum.Repo.preload([:forum])
    |> parent_messages(message)
    |> Subscriptions.list_subscriptions_for_messages()
    |> Enum.reduce(%{}, fn sub, acc -> Map.put(acc, sub.user_id, sub.user) end)
    |> Map.values()
    |> Enum.reject(fn user -> user.user_id == message.user_id end)
    |> Enum.reject(fn user -> Enum.find(already_notified, &(&1.user_id == user.user_id)) != nil end)
    |> Enum.filter(fn user -> may_view?(user, thread, message) end)
    |> Enum.each(fn user -> notify_user_message(user, thread, message) end)
  end

  defp notify_user_message(user, thread, message) do
    settings = Settings.get_setting_for_user(user)
    notify_type = Cforum.ConfigManager.conf(settings, "notify_on_abonement_activity")
    parent = MessageHelpers.parent_message(thread, message)

    [subject, notification_type] =
      if parent && parent.user_id == user.user_id do
        [
          gettext("%{nick} wrote a reply to your message: %{subject}", subject: message.subject, nick: message.author),
          "message:create-answer"
        ]
      else
        [
          gettext("%{nick} wrote a new message: %{subject}", subject: message.subject, nick: message.author),
          "message:create-activity"
        ]
      end

    if notify_type == "email" do
      user
      |> CforumWeb.NotificationMailer.new_message_mail(thread, message)
      |> Cforum.Mailer.deliver!()
    end

    Notifications.create_notification(%{
      recipient_id: user.user_id,
      subject: subject,
      oid: message.message_id,
      otype: notification_type,
      path: Path.message_path(CforumWeb.Endpoint, :show, thread, message)
    })
  end

  defp parent_messages(thread, message, acc \\ [])
  defp parent_messages(_, %Message{parent_id: nil}, acc), do: acc

  defp parent_messages(thread, message, acc) do
    parent = MessageHelpers.parent_message(thread, message)
    parent_messages(thread, parent, [parent | acc])
  end

  defp notify_user_thread(user, thread, message) do
    Notifications.create_notification(%{
      recipient_id: user.user_id,
      subject: gettext("new thread by %{nick}: %{subject}", nick: message.author, subject: message.subject),
      oid: message.message_id,
      otype: "message:create-answer",
      path: Path.message_path(CforumWeb.Endpoint, :show, thread, message)
    })
  end

  defp may_view?(user, thread, message) do
    Cforum.Abilities.may?(
      %{current_user: user, current_forum: thread.forum},
      CforumWeb.MessageController,
      :show,
      {thread, message}
    )
  end

  defp notify_user_mention(user, thread, message) do
    settings = Settings.get_setting_for_user(user)
    notify_type = Cforum.ConfigManager.conf(settings, "notify_on_mention")
    send_mention_notification(user, thread, message, notify_type)
  end

  defp send_mention_notification(_user, _thread, _message, "no"), do: nil

  defp send_mention_notification(user, thread, message, notify_type) do
    subject =
      gettext("%{nick} mentioned you in a new message: “%{subject}”", subject: message.subject, nick: message.author)

    if notify_type == "email" do
      user
      |> CforumWeb.NotificationMailer.new_notification_mail(thread, message, subject)
      |> Cforum.Mailer.deliver!()
    end

    Notifications.create_notification(%{
      recipient_id: user.user_id,
      subject: subject,
      oid: message.message_id,
      otype: "message:mention",
      path: Path.message_path(CforumWeb.Endpoint, :show, thread, message)
    })
  end

  def enqueue(thread, message, type) do
    %{"thread_id" => thread.thread_id, "message_id" => message.message_id, "type" => type}
    |> Cforum.Jobs.NotifyUsersMessageJob.new()
    |> Oban.insert!()
  end
end
