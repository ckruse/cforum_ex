defmodule CforumWeb.Api.V1.MessageController do
  use CforumWeb, :controller

  alias Cforum.Forums
  alias Cforum.Forums.Threads
  alias Cforum.Forums.Messages

  def message_quote(conn, _params) do
    changeset =
      Messages.new_message_changeset(
        conn.assigns.message,
        conn.assigns[:current_user],
        conn.assigns[:visible_forums],
        strip_signature: uconf(conn, "quote_signature") != "yes",
        author: author_from_conn(conn),
        email: email_from_conn(conn),
        homepage: homepage_from_conn(conn),
        greeting: uconf(conn, "greeting"),
        farewell: uconf(conn, "farewell"),
        signature: uconf(conn, "signature"),
        quote: uconf(conn, "quote_by_default") == "yes",
        std_replacement: gettext("all")
      )

    render(conn, "quote.json", changeset: changeset)
  end

  def load_resource(conn) do
    forum = Forums.get_forum_by_slug(conn.params["forum"])

    thread =
      Threads.get_thread_by_slug!(forum, conn.assigns[:visible_forums], conn.params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["message_id"])

    conn
    |> Plug.Conn.assign(:current_forum, forum)
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(_, _, _), do: true
end
