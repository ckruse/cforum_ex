defmodule CforumWeb.Messages.SubscriptionController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Threads, Messages, Thread, Message}
  alias CforumWeb.Views.Helpers.ReturnUrl

  def index(conn, params) do
    count = Messages.count_subscriptions(conn.assigns[:current_user])
    paging = paginate(count, page: params["p"])

    entries = Messages.list_subscriptions(conn.assigns[:current_user], limit: paging.params)

    messages =
      Enum.map(entries, fn msg ->
        thread = %Thread{msg.thread | message: msg}
        %Message{msg | thread: thread}
      end)

    render(conn, "index.html", messages: messages, paging: paging)
  end

  def subscribe(conn, params) do
    Messages.subscribe_message(conn.assigns[:current_user], conn.assigns.message)

    conn
    |> put_flash(:info, gettext("Message was successfully subscribed."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def unsubscribe(conn, params) do
    Messages.unsubscribe_message(conn.assigns[:current_user], conn.assigns.message)

    conn
    |> put_flash(:info, gettext("Message was successfully unsubscribed."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def load_resource(conn) do
    if Phoenix.Controller.action_name(conn) == :index do
      conn
    else
      {thread, message} =
        Messages.get_message_from_slug_and_mid!(
          conn.assigns[:current_forum],
          conn.assigns[:current_user],
          Threads.slug_from_params(conn.params),
          conn.params["mid"],
          message_order: uconf(conn, "sort_messages")
        )

      conn
      |> Plug.Conn.assign(:thread, thread)
      |> Plug.Conn.assign(:message, message)
    end
  end
end
