defmodule CforumWeb.Api.V1.Messages.InterestingController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias Cforum.Forums.Messages

  def interesting(conn, %{"slug" => slug, "message_id" => mid, "forum" => fslug}) do
    forum = Enum.find(conn.assigns.visible_forums, &(&1.slug == fslug))

    thread =
      Threads.get_thread_by_slug!(forum, nil, slug)
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, mid)

    Messages.mark_message_interesting(conn.assigns[:current_user], message)

    thread =
      Threads.get_thread_by_slug!(forum, nil, slug)
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.apply_user_infos(conn.assigns.current_user,
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    conn
    |> put_layout(false)
    |> render(CforumWeb.ThreadView, "thread.html", conn: conn, thread: thread)
  end

  def boring(conn, %{"slug" => slug, "message_id" => mid, "forum" => fslug}) do
    forum = Enum.find(conn.assigns.visible_forums, &(&1.slug == fslug))

    thread =
      Threads.get_thread_by_slug!(forum, nil, slug)
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, mid)

    Messages.mark_message_boring(conn.assigns[:current_user], message)

    thread =
      Threads.get_thread_by_slug!(forum, nil, slug)
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.apply_user_infos(conn.assigns.current_user,
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    conn
    |> put_layout(false)
    |> render(CforumWeb.ThreadView, "thread.html", conn: conn, thread: thread)
  end

  def allowed?(conn, _, _), do: signed_in?(conn)
end
