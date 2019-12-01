defmodule CforumWeb.Api.V1.MessageController do
  use CforumWeb, :controller

  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.Messages
  alias Cforum.ConfigManager
  alias Cforum.Helpers
  alias CforumWeb.Views.ViewHelpers

  def message_quote(conn, params) do
    changeset =
      Messages.new_message_changeset(
        conn.assigns.message,
        conn.assigns[:current_user],
        conn.assigns[:visible_forums],
        %{},
        strip_signature: ConfigManager.uconf(conn, "quote_signature") != "yes",
        author: ViewHelpers.author_from_conn(conn),
        email: ViewHelpers.email_from_conn(conn),
        homepage: ViewHelpers.homepage_from_conn(conn),
        greeting: ConfigManager.uconf(conn, "greeting"),
        farewell: ConfigManager.uconf(conn, "farewell"),
        signature: ConfigManager.uconf(conn, "signature"),
        quote: quote?(conn, params),
        std_replacement: gettext("all")
      )

    render(conn, "quote.json", changeset: changeset)
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

  def allowed?(_, _, _), do: true

  defp quote?(conn, params) do
    if Helpers.blank?(params["with_quote"]),
      do: ConfigManager.uconf(conn, "quote_by_default") == "yes",
      else: params["with_quote"] == "yes"
  end
end
