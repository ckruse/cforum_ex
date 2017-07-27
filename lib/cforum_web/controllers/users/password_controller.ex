defmodule CforumWeb.Users.PasswordController do
  use CforumWeb, :controller

  plug CforumWeb.Plug.AuthorizeAccess, only: [:edit, :update]

  alias Cforum.Accounts.Users

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
