defmodule Cforum.Forums.NotifyUsersMessageJob do
  import CforumWeb.Gettext

  alias Cforum.Forums.{Thread, Message}
  alias Cforum.Forums.Messages
  alias Cforum.Accounts.{Settings, Notifications, Users}
  alias CforumWeb.Views.Helpers.Path

  @spec notify_users_about_new_message(%Thread{}, %Message{}) :: any()
  def notify_users_about_new_message(thread, message) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      parent_messages(thread, message)
      |> Messages.list_subscriptions_for_messages()
      |> Enum.reduce(%{}, fn sub, acc -> Map.put(acc, sub.user_id, sub.user) end)
      |> Map.values()
      |> Enum.reject(fn user -> user.user_id == message.user_id end)
      |> Enum.filter(fn user -> may_view?(user, thread, message) end)
      |> Enum.each(fn user -> notify_user_message(user, thread, message) end)
    end)
  end

  defp notify_user_message(user, thread, message) do
    settings = Settings.get_setting_for_user(user)
    notify_type = Cforum.ConfigManager.conf(settings, "notify_on_abonement_activity")
    parent = Messages.parent_message(thread, message)

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
      |> Cforum.Mailer.deliver_later()
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
    parent = Messages.parent_message(thread, message)
    parent_messages(thread, parent, [parent | acc])
  end

  def notify_users_about_new_thread(thread, message) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      Users.list_users_by_config_option("notify_on_new_thread", "yes")
      |> Enum.reject(fn user -> user.user_id == message.user_id end)
      |> Enum.filter(fn user -> may_view?(user, thread, message) end)
      |> Enum.each(fn user -> notify_user_thread(user, thread, message) end)
    end)
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
end
