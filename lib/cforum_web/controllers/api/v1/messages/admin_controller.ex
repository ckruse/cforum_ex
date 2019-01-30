defmodule CforumWeb.Api.V1.Messages.AdminController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias Cforum.Forums.Messages

  def delete(conn, %{"slug" => slug}) do
    Messages.delete_message(conn.assigns.current_user, conn.assigns.message)
    render_thread(conn, slug)
  end

  def restore(conn, %{"slug" => slug}) do
    Messages.restore_message(conn.assigns.current_user, conn.assigns.message)
    render_thread(conn, slug)
  end

  def no_answer(conn, %{"slug" => slug}) do
    Messages.flag_no_answer(conn.assigns.current_user, conn.assigns.message)
    render_thread(conn, slug)
  end

  def answer(conn, %{"slug" => slug}) do
    Messages.unflag_no_answer(conn.assigns.current_user, conn.assigns.message)
    render_thread(conn, slug)
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns.visible_forums, conn.params["slug"])
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["message_id"])

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
    |> Plug.Conn.assign(:view_all, true)
  end

  def allowed?(conn, _, thread) do
    thread = thread || conn.assigns.thread
    access_forum?(conn.assigns[:current_user], thread.forum, :moderate)
  end

  defp render_thread(conn, slug) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns.visible_forums, slug)
      |> Threads.apply_user_infos(conn.assigns[:current_user])
      |> Threads.apply_user_infos(conn.assigns.current_user,
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    conn
    |> put_layout(false)
    |> put_view(CforumWeb.ThreadView)
    |> render("thread.html", conn: conn, thread: thread)
  end
end
