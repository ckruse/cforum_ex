defmodule CforumWeb.NotificationMailer do
  use Bamboo.Phoenix, view: CforumWeb.NotificationMailerView

  import CforumWeb.Gettext

  @spec pm_notification_mail(%Cforum.Accounts.User{}, %Cforum.Accounts.PrivMessage{}) :: Bamboo.Email.t()
  def pm_notification_mail(user, pm) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(gettext("new private message: “%{subject}”", subject: pm.subject))
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:pm_notification_mail, user: user, pm: pm)
  end

  @spec new_message_mail(%Cforum.Accounts.User{}, %Cforum.Threads.Thread{}, %Cforum.Messages.Message{}) ::
          Bamboo.Email.t()
  def new_message_mail(user, thread, message) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(gettext("new message: “%{subject}”", subject: message.subject))
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:new_message_mail, user: user, thread: thread, message: message)
  end

  def new_notification_mail(user, thread, message, msg_subject) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(gettext("new notification: “%{subject}”", subject: msg_subject))
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:new_message_mail, user: user, thread: thread, message: message)
  end

  def moderation_mail(user, moderation_queue_entry, thread, message) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(gettext("new moderation queue entry: “%{subject}”", subject: message.subject))
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:moderation_mail,
      moderation_queue_entry: moderation_queue_entry,
      user: user,
      thread: thread,
      message: message
    )
  end

  def new_open_close_vote(user, thread, message, vote, subject) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(subject)
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:new_open_close_vote, vote: vote, user: user, thread: thread, message: message)
  end
end
