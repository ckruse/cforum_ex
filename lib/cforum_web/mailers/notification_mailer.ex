defmodule CforumWeb.NotificationMailer do
  use Bamboo.Phoenix, view: CforumWeb.NotificationMailerView

  @spec pm_notification_mail(%Cforum.Accounts.User{}, %Cforum.Accounts.PrivMessage{}) :: Bamboo.Email.t()
  def pm_notification_mail(user, pm) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(pm.subject)
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:pm_notification_mail, user: user, pm: pm)
  end

  @spec new_message_mail(%Cforum.Accounts.User{}, %Cforum.Forums.Thread{}, %Cforum.Forums.Message{}) :: Bamboo.Email.t()
  def new_message_mail(user, thread, message) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(message.subject)
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:new_message_mail, user: user, thread: thread, message: message)
  end

  def new_notification_mail(user, thread, message, msg_subject) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(msg_subject)
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:new_message_mail, user: user, thread: thread, message: message)
  end
end
