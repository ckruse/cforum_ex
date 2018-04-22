defmodule CforumWeb.Messages.InterestingController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Threads, Thread, Messages, Message}
  alias CforumWeb.Views.Helpers.ReturnUrl

  def index(conn, params) do
    count = Messages.count_interesting_messages(conn.assigns[:current_user])
    paging = paginate(count, page: params["p"])

    entries = Messages.list_interesting_messages(conn.assigns[:current_user], limit: paging.params)

    messages =
      Enum.map(entries, fn msg ->
        thread = %Thread{msg.thread | message: msg}
        %Message{msg | thread: thread}
      end)

    render(
      conn,
      "index.html",
      messages: messages,
      paging: paging
    )
  end

  def interesting(conn, params) do
    {thread, message} =
      Messages.get_message_from_slug_and_mid!(
        conn.assigns[:current_forum],
        conn.assigns[:current_user],
        Threads.slug_from_params(params),
        params["mid"],
        message_order: uconf(conn, "sort_messages")
      )

    Messages.mark_message_interesting(conn.assigns[:current_user], message)

    conn
    |> put_flash(:info, gettext("Message was successfully marked as interesting."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end

  def boring(conn, params) do
    {thread, message} =
      Messages.get_message_from_slug_and_mid!(
        conn.assigns[:current_forum],
        conn.assigns[:current_user],
        Threads.slug_from_params(params),
        params["mid"],
        message_order: uconf(conn, "sort_messages")
      )

    Messages.mark_message_boring(conn.assigns[:current_user], message)

    conn
    |> put_flash(:info, gettext("Interesting mark was successfully removed."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end
end
