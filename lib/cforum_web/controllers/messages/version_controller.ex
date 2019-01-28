defmodule CforumWeb.Messages.VersionController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Messages, Threads}

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, Threads.slug_from_params(conn.params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["mid"])

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(_, _, _), do: true
end
