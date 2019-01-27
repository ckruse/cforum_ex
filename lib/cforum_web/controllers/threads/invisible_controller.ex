defmodule CforumWeb.Threads.InvisibleController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias CforumWeb.Views.Helpers.ReturnUrl

  def index(conn, params) do
    page = parse_page(params["p"]) - 1
    limit = uconf(conn, "pagination", :int)
    user = conn.assigns[:current_user]
    ordering = uconf(conn, "sort_threads")

    {all_threads_count, threads} =
      Threads.list_invisible_threads(
        user,
        conn.assigns[:visible_forums],
        page: page,
        limit: limit,
        order: ordering,
        view_all: conn.assigns[:view_all]
      )

    threads =
      threads
      |> Threads.apply_user_infos(user,
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )
      |> Threads.build_message_trees(uconf(conn, "sort_messages"))

    p = paginate(all_threads_count, per_page: limit, page: page + 1)

    render(conn, "index.html", threads: threads, all_threads_count: all_threads_count, page: p)
  end

  def hide(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        Threads.slug_from_params(params)
      )
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    Threads.hide_thread(conn.assigns[:current_user], thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been hidden."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end

  def unhide(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        Threads.slug_from_params(params)
      )
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    Threads.unhide_thread(conn.assigns[:current_user], thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been restored."))
    |> redirect(to: Path.invisible_thread_path(conn, :index))
  end

  def allowed?(conn, _, _), do: signed_in?(conn)
end
