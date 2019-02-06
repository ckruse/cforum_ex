defmodule CforumWeb.Messages.InterestingController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Threads, Thread, Messages, Message}
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

    count = Finder.count_interesting_messages_results(conn.assigns[:current_user], changeset)
    paging = paginate(count, page: params["p"])

    threads =
      Finder.search_interesting_messages(conn.assigns.current_user, changeset, paging.params)
      |> Enum.map(fn msg -> %Thread{msg.thread | messages: [msg]} end)
      |> Threads.apply_user_infos(conn.assigns[:current_user])
      |> Threads.apply_highlights(conn)
      |> Enum.map(fn thread -> %Thread{thread | message: List.first(thread.messages)} end)

    render(conn, "index.html", threads: threads, paging: paging, changeset: changeset)
  end

  def index(conn, params) do
    visible_sections = Search.list_visible_search_sections(conn.assigns.visible_forums)
    changeset = Search.search_changeset(visible_sections)

    count = Messages.count_interesting_messages(conn.assigns[:current_user])
    paging = paginate(count, page: params["p"])

    threads =
      Messages.list_interesting_messages(conn.assigns[:current_user], limit: paging.params)
      |> Enum.map(fn msg -> %Thread{msg.thread | messages: [msg]} end)
      |> Threads.apply_user_infos(conn.assigns[:current_user])
      |> Threads.apply_highlights(conn)
      |> Enum.map(fn thread -> %Thread{thread | message: List.first(thread.messages)} end)

    render(conn, "index.html", threads: threads, paging: paging, changeset: changeset)
  end

  def interesting(conn, params) do
    Messages.mark_message_interesting(conn.assigns[:current_user], conn.assigns.message)

    conn
    |> put_flash(:info, gettext("Message was successfully marked as interesting."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread, conn.assigns.message))
  end

  def boring(conn, params) do
    Messages.mark_message_boring(conn.assigns[:current_user], conn.assigns.message)

    conn
    |> put_flash(:info, gettext("Interesting mark was successfully removed."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread, conn.assigns.message))
  end

  def load_resource(conn) do
    if Phoenix.Controller.action_name(conn) == :index do
      conn
    else
      thread =
        Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, Threads.slug_from_params(conn.params))
        |> Threads.reject_deleted_threads(conn.assigns[:view_all])
        |> Threads.apply_user_infos(conn.assigns[:current_user], omit: [:read, :subscriptions, :open_close])
        |> Threads.apply_highlights(conn)
        |> Threads.build_message_tree(uconf(conn, "sort_messages"))

      message = Messages.get_message_from_mid!(thread, conn.params["mid"])

      conn
      |> Plug.Conn.assign(:thread, thread)
      |> Plug.Conn.assign(:message, message)
    end
  end

  def allowed?(conn, :interesting, message) do
    message = message || conn.assigns.message
    signed_in?(conn) && message.attribs[:is_interesting] != true
  end

  def allowed?(conn, :boring, message) do
    message = message || conn.assigns.message
    signed_in?(conn) && message.attribs[:is_interesting] == true
  end

  def allowed?(conn, _, _), do: signed_in?(conn)
end
