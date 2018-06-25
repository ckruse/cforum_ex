defmodule CforumWeb.Admin.GroupController do
  use CforumWeb, :controller

  alias Cforum.Accounts.Groups
  alias Cforum.Accounts.Group

  def index(conn, _params) do
    groups = Groups.list_groups()
    render(conn, "index.html", groups: groups)
  end

  def new(conn, _params) do
    changeset = Groups.change_group(%Group{})
    forums = Cforum.Forums.list_forums()
    render(conn, "new.html", changeset: changeset, forums: forums)
  end

  def create(conn, %{"group" => group_params}) do
    case Groups.create_group(conn.assigns.current_user, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, gettext("The group has been created successfully."))
        |> redirect(to: admin_group_path(conn, :edit, group))

      {:error, %Ecto.Changeset{} = changeset} ->
        forums = Cforum.Forums.list_forums()
        render(conn, "new.html", changeset: changeset, forums: forums)
    end
  end

  def edit(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    changeset = Groups.change_group(group)
    forums = Cforum.Forums.list_forums()
    render(conn, "edit.html", group: group, changeset: changeset, forums: forums)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Groups.get_group!(id)

    case Groups.update_group(conn.assigns.current_user, group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, gettext("The group has been updated successfully."))
        |> redirect(to: admin_group_path(conn, :edit, group))

      {:error, %Ecto.Changeset{} = changeset} ->
        forums = Cforum.Forums.list_forums()
        render(conn, "edit.html", group: group, changeset: changeset, forums: forums)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    {:ok, _group} = Groups.delete_group(conn.assigns.current_user, group)

    conn
    |> put_flash(:info, gettext("The group has been deleted successfully."))
    |> redirect(to: admin_group_path(conn, :index))
  end
end
