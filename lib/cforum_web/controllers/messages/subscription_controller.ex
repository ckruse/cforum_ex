defmodule CforumWeb.Messages.SubscriptionController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Threads, Messages, Thread, Message}
  alias CforumWeb.Views.Helpers.ReturnUrl
  alias Cforum.Search
  alias Cforum.Search.Finder

  def index(conn, %{"search" => search_params} = params) do
    visible_sections = Search.list_visible_search_sections(conn.assigns.visible_forums)

    changeset =
      Search.search_changeset(
        visible_sections,
        Map.put(search_params, "sections", Enum.map(visible_sections, & &1.search_section_id))
      )

    count = Finder.count_subscribed_messages_results(conn.assigns[:current_user], changeset)
    paging = paginate(count, page: params["p"])

    messages =
      Finder.search_subscribed_messages(conn.assigns.current_user, changeset, paging.params)
      |> Enum.map(fn msg ->
        thread = %Thread{msg.thread | message: msg}
        %Message{msg | thread: thread}
      end)

    render(conn, "index.html", messages: messages, paging: paging, changeset: changeset)
  end

  def index(conn, params) do
    visible_sections = Search.list_visible_search_sections(conn.assigns.visible_forums)
    changeset = Search.search_changeset(visible_sections)
    count = Messages.count_subscriptions(conn.assigns[:current_user])
    paging = paginate(count, page: params["p"])

    entries = Messages.list_subscriptions(conn.assigns[:current_user], limit: paging.params)

    messages =
      Enum.map(entries, fn msg ->
        thread = %Thread{msg.thread | message: msg}
        %Message{msg | thread: thread}
      end)

    render(conn, "index.html", messages: messages, paging: paging, changeset: changeset)
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

  def allowed?(conn, :subscribe, message) do
    message = message || conn.assigns.message
    signed_in?(conn) && message.attribs[:is_subscribed] != true
  end

  def allowed?(conn, :unsubscribe, message) do
    message = message || conn.assigns.message
    signed_in?(conn) && message.attribs[:is_subscribed] == true
  end

  def allowed?(conn, _, _), do: signed_in?(conn)
end
