defmodule Cforum.Forums.NotifyUsersMessageJob do
  import CforumWeb.Gettext

  alias Cforum.Forums.{Thread, Message}
  alias Cforum.Forums.Messages
  alias Cforum.Accounts.{Settings, Notifications}
  alias CforumWeb.Views.Helpers.Path

  @spec notify_users_about_new_message(%Thread{}, %Message{}) :: any()
  def notify_users_about_new_message(thread, message) do
    Task.start(fn ->
      parent_messages(thread, message)
      |> Messages.list_subscriptions_for_messages()
      |> Enum.reduce(%{}, fn sub, acc -> Map.put(acc, sub.user_id, sub.user) end)
      |> Map.values()
      |> Enum.reject(fn user -> user.user_id == message.user_id end)
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
end
