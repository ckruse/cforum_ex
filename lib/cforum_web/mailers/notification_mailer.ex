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
end
