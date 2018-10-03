defmodule CforumWeb.Api.V1.Messages.MarkReadController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias Cforum.Forums.Messages

  def mark_read(conn, %{"slug" => slug}) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        conn.assigns.current_user,
        slug
      )

    Messages.mark_messages_read(conn.assigns[:current_user], thread.messages)

    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        conn.assigns.current_user,
        slug,
        message_order: uconf(conn, "sort_messages"),
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )

    conn
    |> put_layout(false)
    |> render(CforumWeb.ThreadView, "thread.html", conn: conn, thread: thread)
  end

  def allowed?(conn, _, _), do: signed_in?(conn)
end
