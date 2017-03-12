defmodule Cforum.UserMailer do
  use Bamboo.Phoenix, view: Cforum.UserMailerView
  import Cforum.Gettext

  def confirmation_mail(user) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(gettext("confirm your registration"))
    |> put_html_layout({Cforum.LayoutView, "email.html"})
    |> render(:confirmation_mail, user: user)
  end

end
