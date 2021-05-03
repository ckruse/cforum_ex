defmodule CforumWeb.NotificationMailer do
  use Phoenix.Swoosh, view: CforumWeb.NotificationMailerView, layout: {CforumWeb.LayoutView, :email}
  import CforumWeb.Gettext

  alias Cforum.ConfigManager

  def pm_notification_mail(user, pm) do
    new()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to({user.username, user.email})
    |> Swoosh.Email.header("Auto-Submitted", "auto-generated")
    |> subject(gettext("new private message: “%{subject}”", subject: pm.subject))
    |> render_body(:pm_notification_mail, %{user: user, pm: pm})
  end

  def new_message_mail(user, thread, message) do
    new()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to({user.username, user.email})
    |> Swoosh.Email.header("Auto-Submitted", "auto-generated")
    |> subject(gettext("new message: “%{subject}”", subject: message.subject))
    |> render_body(:new_message_mail, %{
      user: user,
      thread: thread,
      message: message,
      conn: build_conn(thread.forum, user)
    })
  end

  def new_notification_mail(user, thread, message, msg_subject) do
    new()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to({user.username, user.email})
    |> Swoosh.Email.header("Auto-Submitted", "auto-generated")
    |> subject(gettext("new notification: “%{subject}”", subject: msg_subject))
    |> render_body(:new_message_mail, %{
      user: user,
      thread: thread,
      message: message,
      conn: build_conn(thread.forum, user)
    })
  end

  def moderation_mail(user, moderation_queue_entry, thread, message) do
    new()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to({user.username, user.email})
    |> Swoosh.Email.header("Auto-Submitted", "auto-generated")
    |> subject(gettext("new moderation queue entry: “%{subject}”", subject: message.subject))
    |> render_body(:moderation_mail, %{
      moderation_queue_entry: moderation_queue_entry,
      user: user,
      thread: thread,
      message: message
    })
  end

  def inactivity_notification_error_mail(user, error, recipients) do
    new()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(Enum.map(recipients, & &1.email))
    |> Swoosh.Email.header("Auto-Submitted", "auto-generated")
    |> subject(gettext("error sending inactivity notification email"))
    |> render_body(:inactivity_notification_error, %{user: user, error: error})
  end

  defp build_conn(forum, user) do
    settings = ConfigManager.settings_map(forum, user)

    %Plug.Conn{
      assigns: %{
        global_config: settings[:global],
        forum_config: settings[:forum],
        user_config: settings[:user],
        current_user: user
      }
    }
  end
end
