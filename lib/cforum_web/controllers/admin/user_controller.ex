defmodule CforumWeb.Admin.UserController do
  use CforumWeb, :controller

  alias Cforum.Accounts.{Users, User}

  def index(conn, params) do
    {sort_params, conn} = sort_collection(conn, [:username, :score, :activity, :created_at])
    count = Users.count_users()
    paging = paginate(count, page: params["p"])
    users = Users.list_users(limit: paging.params, order: sort_params, search: params["s"])

    render(conn, "index.html", users: users, paging: paging, s: params["s"])
  end

  def new(conn, _params) do
    changeset = Users.admin_change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Users.admin_create_user(conn.assigns.current_user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("The user has been created successfully."))
        |> redirect(to: admin_user_path(conn, :edit, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    changeset = Users.admin_change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    case Users.admin_update_user(conn.assigns.current_user, user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User updated successfully."))
        |> redirect(to: admin_user_path(conn, :edit, user))

      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _user} = Users.delete_user(conn.assigns.current_user, user)

    conn
    |> put_flash(:info, gettext("User deleted successfully."))
    |> redirect(to: admin_user_path(conn, :index))
  end

  def allowed?(conn, _, _), do: admin?(conn)
end
