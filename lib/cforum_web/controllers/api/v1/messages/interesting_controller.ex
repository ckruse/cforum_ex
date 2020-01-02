defmodule CforumWeb.Api.V1.Messages.InterestingController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.Messages
  alias Cforum.InterestingMessages
  alias Cforum.ConfigManager

  def interesting(conn, _params) do
    InterestingMessages.mark_message_interesting(conn.assigns[:current_user], conn.assigns.message)
    render_thread(conn)
  end

  def boring(conn, _params) do
    InterestingMessages.mark_message_boring(conn.assigns[:current_user], conn.assigns.message)
    render_thread(conn)
  end

  def load_resource(conn) do
    forum = Forums.get_forum_by_slug(conn.params["forum"])

    thread =
      Threads.get_thread_by_slug!(forum, conn.assigns[:visible_forums], conn.params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()

    message = Messages.get_message_from_mid!(thread, conn.params["message_id"])

    conn
    |> Plug.Conn.assign(:current_forum, forum)
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(conn, _, _), do: Abilities.signed_in?(conn)

  defp render_thread(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], conn.assigns[:visible_forums], conn.params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns.current_user,
        close_read_threads:
          ConfigManager.uconf(conn, "open_close_close_when_read") == "yes" && conn.params["fold"] != "no",
        open_close_default_state: ConfigManager.uconf(conn, "open_close_default")
      )
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    conn
    |> put_layout(false)
    |> put_view(CforumWeb.ThreadView)
    |> render("thread.html", conn: conn, thread: thread)
  end
end
