defmodule CforumWeb.Users.PasswordController do
  use CforumWeb, :controller

  alias Cforum.Accounts.Users
  alias Cforum.Accounts.User

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"login" => login}}) do
    case Users.get_user_by_username_or_email(login) do
      %User{} = user ->
        Users.get_reset_password_token(user)
        |> CforumWeb.UserMailer.reset_password_mail()
        |> Cforum.Mailer.deliver_later()

        conn
        |> put_flash(:info, gettext("The instructions how to reset your password have been sent."))
        |> redirect(to: root_path(conn, :index))

      _ ->
        render(conn, "new.html")
    end
  end

  def edit_reset(conn, %{"token" => reset_token}) do
    user = Users.get_user_by_reset_password_token!(reset_token)
    changeset = Users.change_user_password(user)

    render(
      conn,
      "edit_reset.html",
      user: user,
      changeset: changeset,
      token: reset_token
    )
  end

  def update_reset(conn, %{"token" => reset_token, "user" => user_params}) do
    user = Users.get_user_by_reset_password_token!(reset_token)

    case Users.update_user_password(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Password updated successfully."))
        |> put_session(:user_id, user.user_id)
        |> configure_session(renew: true)
        |> redirect(to: root_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit_reset.html",
          user: user,
          changeset: changeset,
          token: reset_token
        )
    end
  end

  def edit(conn, %{"user_id" => id}) do
    user = Users.get_user!(id)
    changeset = Users.change_user_password(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user_id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    case Users.update_user_password(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Password updated successfully."))
        |> redirect(to: user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end
end
