defmodule CforumWeb.Users.RegistrationController do
  use CforumWeb, :controller

  plug CforumWeb.Plug.EnsureAnonymous

  alias Cforum.Accounts.Users
  alias Cforum.Accounts.User

  def new(conn, _params) do
    changeset = User.register_changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Users.register_user(user_params) do
      {:ok, user} ->
        CforumWeb.UserMailer.confirmation_mail(user)
        |> Cforum.Mailer.deliver_later

        conn
        |> put_flash(:info, gettext("Account successfully created. Please follow the confirmation instructions we send you via mail."))
        |> redirect(to: forum_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def confirm(conn, %{"token" => token}) do
    case Users.confirm_user(token) do
      {:ok, user} ->
        conn
        |> Plug.Conn.put_session(:user_id, user.user_id)
        |> Plug.Conn.configure_session(renew: true)
        |> put_flash(:info, gettext("Account successfully confirmed!"))
        |> redirect(to: forum_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, gettext("Oops, something went wrong!"))
        |> redirect(to: forum_path(conn, :index))
    end
  end


end
