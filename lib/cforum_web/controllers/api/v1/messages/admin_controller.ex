defmodule CforumWeb.Api.V1.Messages.AdminController do
  use CforumWeb, :controller

  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.Messages

  alias Cforum.Abilities
  alias Cforum.Helpers
  alias Cforum.ConfigManager

  def delete(conn, %{"slug" => slug} = args) do
    reason =
      if args["reason"] == "custom",
        do: args["custom"],
        else: args["reason"]

    Messages.delete_message(conn.assigns.current_user, conn.assigns.message, reason)
    render_thread(conn, slug)
  end

  def restore(conn, %{"slug" => slug}) do
    Messages.restore_message(conn.assigns.current_user, conn.assigns.message)
    render_thread(conn, slug)
  end

  def no_answer(conn, %{"slug" => slug} = args) do
    reason =
      if args["reason"] == "custom",
        do: args["custom"],
        else: args["reason"]

    Messages.flag_no_answer(conn.assigns.current_user, conn.assigns.message, reason)
    render_thread(conn, slug)
  end

  def answer(conn, %{"slug" => slug}) do
    Messages.unflag_no_answer(conn.assigns.current_user, conn.assigns.message)
    render_thread(conn, slug)
  end

  def load_resource(conn) do
    forum = Forums.get_forum_by_slug(conn.params["forum"])

    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns.visible_forums, conn.params["slug"])
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["message_id"])

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
    |> Plug.Conn.assign(:view_all, true)
    |> Plug.Conn.assign(:current_forum, forum)
  end

  defp no_reason?(conn) do
    Helpers.blank?(conn.params["reason"]) ||
      (conn.params["reason"] == "custom" && Helpers.blank?(conn.params["custom"])) || conn.params["no_reason"] == "true"
  end

  def allowed?(conn, action, thread) when action in [:delete, :no_answer] do
    thread = thread || conn.assigns.thread

    if no_reason?(conn) do
      Abilities.admin?(conn.assigns[:current_user])
    else
      Abilities.access_forum?(conn.assigns[:current_user], thread.forum, :moderate)
    end
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
        close_read_threads: ConfigManager.uconf(conn, "open_close_close_when_read") == "yes",
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
