defmodule Cforum.Web.Admin.ForumController do
  use Cforum.Web, :controller

  alias Cforum.Forums.Forum

  def index(conn, _params) do
    forums = Repo.all(Forum)
    render(conn, "index.html", forums: forums)
  end

  def new(conn, _params) do
    changeset = Forum.changeset(%Forum{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"forum" => forum_params}) do
    changeset = Forum.changeset(%Forum{}, forum_params)

    case Repo.insert(changeset) do
      {:ok, _forum} ->
        conn
        |> put_flash(:info, "Forum created successfully.")
        |> redirect(to: admin_forum_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => slug}) do
    forum = Repo.get_by!(Forum, slug: slug)
    render(conn, "show.html", forum: forum)
  end

  def edit(conn, %{"id" => slug}) do
    forum = Repo.get_by!(Forum, slug: slug)
    changeset = Forum.changeset(forum)
    render(conn, "edit.html", forum: forum, changeset: changeset)
  end

  def update(conn, %{"id" => slug, "forum" => forum_params}) do
    forum = Repo.get_by!(Forum, slug: slug)
    changeset = Forum.changeset(forum, forum_params)

    case Repo.update(changeset) do
      {:ok, forum} ->
        conn
        |> put_flash(:info, "Forum updated successfully.")
        |> redirect(to: admin_forum_path(conn, :show, forum))
      {:error, changeset} ->
        render(conn, "edit.html", forum: forum, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => slug}) do
    forum = Repo.get_by!(Forum, slug: slug)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(forum)

    conn
    |> put_flash(:info, "Forum deleted successfully.")
    |> redirect(to: admin_forum_path(conn, :index))
  end
end
