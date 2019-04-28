defmodule CforumWeb.Api.V1.Threads.AdminController do
  use CforumWeb, :controller

  alias Cforum.Threads

  def sticky(conn, %{"slug" => slug}) do
    Threads.mark_thread_sticky(conn.assigns.current_user, conn.assigns.thread)
    render_thread(conn, slug)
  end

  def unsticky(conn, %{"slug" => slug}) do
    Threads.mark_thread_unsticky(conn.assigns.current_user, conn.assigns.thread)
    render_thread(conn, slug)
  end

  def no_archive(conn, %{"slug" => slug}) do
    Threads.flag_thread_no_archive(conn.assigns.current_user, conn.assigns.thread)
    render_thread(conn, slug)
  end

  def archive(conn, %{"slug" => slug}) do
    Threads.flag_thread_archive(conn.assigns.current_user, conn.assigns.thread)
    render_thread(conn, slug)
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], conn.assigns[:visible_forums], conn.params["slug"])

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:view_all, true)
  end

  def allowed?(conn, _, thread) do
    thread = thread || conn.assigns.thread
    Abilities.access_forum?(conn.assigns[:current_user], thread.forum, :moderate)
  end

  defp render_thread(conn, slug) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns.visible_forums, slug)
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns.current_user,
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    conn
    |> put_layout(false)
    |> put_view(CforumWeb.ThreadView)
    |> render("thread.html", conn: conn, thread: thread)
  end
end
