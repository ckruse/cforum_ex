defmodule CforumWeb.Admin.ForumController do
  use CforumWeb, :controller

  alias Cforum.Forums
  alias Cforum.Forums.Forum
  alias Cforum.Accounts.Setting

  def index(conn, _params) do
    forums = Forums.list_forums()
    render(conn, "index.html", forums: forums)
  end

  def new(conn, _params) do
    changeset = Forums.change_forum(%Forum{})
    render(conn, "new.html", changeset: changeset, forum: %Forum{setting: %Setting{}})
  end

  def create(conn, %{"forum" => forum_params}) do
    case Forums.create_forum(conn.assigns.current_user, forum_params) do
      {:ok, forum} ->
        conn
        |> put_flash(:info, gettext("Forum created successfully."))
        |> redirect(to: Routes.admin_forum_path(conn, :edit, forum))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, forum: %Forum{setting: %Setting{}})
    end
  end

  def edit(conn, %{"id" => slug}) do
    forum = Forums.get_forum_by_slug!(slug)
    changeset = Forums.change_forum(forum)
    render(conn, "edit.html", forum: forum, changeset: changeset)
  end

  def update(conn, %{"id" => slug, "forum" => forum_params}) do
    forum = Forums.get_forum_by_slug!(slug)

    case Forums.update_forum(conn.assigns.current_user, forum, forum_params) do
      {:ok, forum} ->
        conn
        |> put_flash(:info, gettext("Forum updated successfully."))
        |> redirect(to: Routes.admin_forum_path(conn, :edit, forum))

      {:error, changeset} ->
        render(conn, "edit.html", forum: forum, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => slug}) do
    forum = Forums.get_forum_by_slug!(slug)
    {:ok, _forum} = Forums.delete_forum(conn.assigns.current_user, forum)

    conn
    |> put_flash(:info, gettext("Forum deleted successfully."))
    |> redirect(to: Routes.admin_forum_path(conn, :index))
  end

  def allowed?(conn, _, _), do: admin?(conn)
end
