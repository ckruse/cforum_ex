defmodule CforumWeb.UserMailer do
  use Phoenix.Swoosh, view: CforumWeb.UserMailerView, layout: {CforumWeb.LayoutView, :email}
  import CforumWeb.Gettext

  def confirmation_mail(user) do
    new()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to({user.username, user.email})
    |> Swoosh.Email.header("Auto-Submitted", "auto-generated")
    |> subject(gettext("confirm your registration"))
    |> render_body(:confirmation_mail, %{user: user})
  end

  def reset_password_mail(user) do
    new()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to({user.username, user.email})
    |> Swoosh.Email.header("Auto-Submitted", "auto-generated")
    |> subject(gettext("reset password instructions"))
    |> render_body(:reset_password_mail, %{user: user})
  end

  @years [
    gettext("since one year"),
    gettext("since two years"),
    gettext("since three years"),
    gettext("since four years"),
    gettext("since five years")
  ]

  def inactivity_mail(user, years) do
    years_str = Enum.at(@years, years - 1, gettext("since %{years} year(s)", years: years))

    new()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to({user.username, user.email})
    |> bcc(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> Swoosh.Email.header("Auto-Submitted", "auto-generated")
    |> subject(gettext("inactivity warning"))
    |> render_body(:inactivity_warning_mail, %{user: user, years: years_str})
  end
end
