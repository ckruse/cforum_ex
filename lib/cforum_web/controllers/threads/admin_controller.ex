defmodule CforumWeb.Threads.AdminController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias CforumWeb.Views.Helpers.ReturnUrl

  def sticky(conn, params) do
    Threads.mark_thread_sticky(conn.assigns.current_user, conn.assigns.thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been marked as sticky."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def unsticky(conn, params) do
    Threads.mark_thread_unsticky(conn.assigns.current_user, conn.assigns.thread)

    conn
    |> put_flash(:info, gettext("Sticky mark has successfully been removed."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def no_archive(conn, params) do
    Threads.flag_thread_no_archive(conn.assigns.current_user, conn.assigns.thread)

    conn
    |> put_flash(:info, gettext("Thread will get deleted on archiving."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def archive(conn, params) do
    Threads.flag_thread_archive(conn.assigns.current_user, conn.assigns.thread)

    conn
    |> put_flash(:info, gettext("Thread will be archived."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def move(conn, _params) do
    changeset = Threads.change_thread(conn.assigns.thread)
    render(conn, "move.html", changeset: changeset, message: List.first(conn.assigns.thread.messages))
  end

  def do_move(conn, %{"thread" => %{"forum_id" => forum_id}}) do
    case Threads.move_thread(conn.assigns.current_user, conn.assigns.thread, forum_id, conn.assigns.visible_forums) do
      {:ok, thread} ->
        conn
        |> put_flash(:info, gettext("Thread has successfully been moved."))
        |> redirect(to: Path.forum_path(conn, :index, thread.forum))

      {:error, changeset} ->
        render(conn, "move.html", changeset: changeset, message: List.first(conn.assigns.thread.messages))
    end
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        Threads.slug_from_params(conn.params)
      )

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:view_all, true)
  end

  def allowed?(conn, _, _), do: access_forum?(conn, :moderate)
end
