defmodule CforumWeb.UserMailer do
  use Bamboo.Phoenix, view: CforumWeb.UserMailerView
  import CforumWeb.Gettext

  @spec confirmation_mail(%Cforum.Accounts.User{}) :: Bamboo.Email.t()
  def confirmation_mail(user) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(gettext("confirm your registration"))
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:confirmation_mail, user: user)
  end

  @spec reset_password_mail(%Cforum.Accounts.User{}) :: Bamboo.Email.t()
  def reset_password_mail(user) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(gettext("reset password instructions"))
    |> put_html_layout({CforumWeb.LayoutView, "email.html"})
    |> render(:reset_password_mail, user: user)
  end
end
