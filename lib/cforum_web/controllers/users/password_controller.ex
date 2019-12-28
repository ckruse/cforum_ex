defmodule CforumWeb.Users.PasswordController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.Accounts.Users
  alias Cforum.Accounts.User

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"login" => login}}) do
    with %User{} = user <- Users.get_user_by_username_or_email(login) do
      Cforum.Jobs.UserMailerJob.enqueue(user, "reset_password")
    end

    conn
    |> put_flash(:info, gettext("The instructions how to reset your password have been sent."))
    |> redirect(to: Path.root_path(conn, :index))
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
        |> redirect(to: Path.root_path(conn, :index))

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
        |> redirect(to: Path.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def allowed?(conn, action, _resource) when action in [:new, :create, :edit_reset, :update_reset],
    do: !Abilities.signed_in?(conn)

  def allowed?(conn, action, resource) when action in [:edit, :update],
    do: CforumWeb.Users.UserController.allowed?(conn, :update, resource)

  def allowed?(_, _, _), do: false
end
