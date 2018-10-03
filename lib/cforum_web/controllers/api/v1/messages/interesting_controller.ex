defmodule CforumWeb.Api.V1.Messages.InterestingController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias Cforum.Forums.Messages

  def interesting(conn, %{"slug" => slug, "message_id" => mid, "forum" => fslug}) do
    forum = Enum.find(conn.assigns.visible_forums, &(&1.slug == fslug))

    {_thread, message} =
      Messages.get_message_from_slug_and_mid!(forum, conn.assigns.current_user, slug, mid,
        message_order: uconf(conn, "sort_messages")
      )

    Messages.mark_message_interesting(conn.assigns[:current_user], message)

    thread =
      Threads.get_thread_by_slug!(forum, conn.assigns.visible_forums, conn.assigns.current_user, slug,
        message_order: uconf(conn, "sort_messages"),
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )

    conn
    |> put_layout(false)
    |> render(CforumWeb.ThreadView, "thread.html", conn: conn, thread: thread)
  end

  def boring(conn, %{"slug" => slug, "message_id" => mid, "forum" => fslug}) do
    forum = Enum.find(conn.assigns.visible_forums, &(&1.slug == fslug))

    {_thread, message} =
      Messages.get_message_from_slug_and_mid!(forum, conn.assigns.current_user, slug, mid,
        message_order: uconf(conn, "sort_messages")
      )

    Messages.mark_message_boring(conn.assigns[:current_user], message)

    thread =
      Threads.get_thread_by_slug!(forum, conn.assigns.visible_forums, conn.assigns.current_user, slug,
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
