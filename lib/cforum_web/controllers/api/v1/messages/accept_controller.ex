defmodule CforumWeb.Api.V1.Messages.AcceptController do
  use CforumWeb, :controller

  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.Messages
  alias Cforum.ConfigManager

  def accept(conn, params) do
    accept_value = ConfigManager.conf(conn, "accept_value", :int)
    Messages.accept_message(conn.assigns.message, conn.assigns.current_user, accept_value)

    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns[:visible_forums], params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    message = Messages.get_message_from_mid!(thread, params["message_id"])

    render(conn, "accept.json", message: message)
  end

  def unaccept(conn, params) do
    Messages.unaccept_message(conn.assigns.message, conn.assigns.current_user)

    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns[:visible_forums], params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    message = Messages.get_message_from_mid!(thread, params["message_id"])

    render(conn, "accept.json", message: message)
  end

  def load_resource(conn) do
    forum = Forums.get_forum_by_slug(conn.params["forum"])

    thread =
      Threads.get_thread_by_slug!(forum, conn.assigns[:visible_forums], conn.params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["message_id"])

    conn
    |> Plug.Conn.assign(:current_forum, forum)
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(conn, action, resource), do: CforumWeb.Messages.AcceptController.allowed?(conn, action, resource)
end
