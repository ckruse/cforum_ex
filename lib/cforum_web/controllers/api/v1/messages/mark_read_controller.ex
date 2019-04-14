defmodule CforumWeb.Api.V1.Messages.MarkReadController do
  use CforumWeb, :controller

  alias Cforum.Forums
  alias Cforum.Forums.Threads
  alias Cforum.Forums.Messages

  def mark_read(conn, %{"slug" => slug} = params) do
    forum = Forums.get_forum_by_slug(params["forum"])

    thread =
      Threads.get_thread_by_slug!(forum, conn.assigns.visible_forums, slug)
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    Messages.mark_messages_read(conn.assigns[:current_user], thread.messages)

    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns.visible_forums, slug)
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns.current_user,
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes" && params["fold"] != "no",
        open_close_default_state: uconf(conn, "open_close_default")
      )
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    conn
    |> put_layout(false)
    |> put_view(CforumWeb.ThreadView)
    |> render("thread.html", conn: conn, thread: thread, current_forum: forum)
  end

  def allowed?(conn, _, _), do: Abilities.signed_in?(conn)
end
