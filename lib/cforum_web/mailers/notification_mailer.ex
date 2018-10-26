defmodule CforumWeb.NotificationMailer do
  use Bamboo.Phoenix, view: CforumWeb.NotificationMailerView

  def pm_notification_mail(user, pm) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(pm.subject)
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:pm_notification_mail, user: user, pm: pm)
  end

  def new_message_mail(user, thread, message) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(message.subject)
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:new_message_mail, user: user, thread: thread, message: message)
  end
end
