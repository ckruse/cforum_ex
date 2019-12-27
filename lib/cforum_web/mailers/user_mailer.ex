defmodule CforumWeb.UserMailer do
  use Phoenix.Swoosh, view: CforumWeb.UserMailerView, layout: {CforumWeb.LayoutView, :email}
  import CforumWeb.Gettext

  def confirmation_mail(user) do
    new()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to({user.username, user.email})
    |> subject(gettext("confirm your registration"))
    |> render_body(:confirmation_mail, %{user: user})
  end

  def reset_password_mail(user) do
    new()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to({user.username, user.email})
    |> subject(gettext("reset password instructions"))
    |> render_body(:reset_password_mail, %{user: user})
  end
end
