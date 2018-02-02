defmodule CforumWeb.ThreadController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias Cforum.Forums.Messages

  def index(conn, params) do
    page = parse_page(params["p"]) - 1
    limit = uconf(conn, "pagination", :int)
    user = conn.assigns[:current_user]
    {set_order_cookie, ordering} = get_ordering(conn, user)

    {all_threads_count, threads} =
      Threads.list_threads(
        conn.assigns[:current_forum],
        conn.assigns[:visible_forums],
        user,
        page: page,
        limit: limit,
        order: ordering,
        view_all: conn.assigns[:view_all],
        hide_read_threads: hide_read_threads?(conn),
        only_wo_answer: conn.params["only_wo_answer"] != nil,
        message_order: uconf(conn, "sort_messages"),
        use_paging: uconf(conn, "page_messages") == "yes",
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )

    p = paginate(all_threads_count, per_page: limit, page: page + 1)

    conn
    |> maybe_set_cookie(set_order_cookie, ordering)
    |> render("index.html", threads: threads, all_threads_count: all_threads_count, page: p)
  end

  def new(conn, _params) do
    changeset =
      Messages.new_message_changeset(
        nil,
        conn.assigns[:current_user],
        conn.assigns[:visible_forums],
        author: author_from_conn(conn),
        email: email_from_conn(conn),
        homepage: homepage_from_conn(conn),
        greeting: uconf(conn, "greeting"),
        farewell: uconf(conn, "farewell"),
        signature: uconf(conn, "signature"),
        std_replacement: gettext("all")
      )

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"message" => message_params} = params) do
    if Map.has_key?(params, "preview"),
      do: show_preview(conn, message_params),
      else: create_thread(conn, message_params)
  end

  def show_preview(conn, params) do
    {thread, message, changeset} =
      Threads.preview_thread(
        params,
        conn.assigns[:current_user],
        conn.assigns[:current_forum],
        conn.assigns[:visible_forums]
      )

    render(conn, "new.html", thread: thread, message: message, changeset: changeset, preview: true)
  end

  def create_thread(conn, params) do
    create_val =
      Threads.create_thread(
        params,
        conn.assigns[:current_user],
        conn.assigns[:current_forum],
        conn.assigns[:visible_forums]
      )

    case create_val do
      {:ok, thread, message} ->
        conn
        |> put_flash(:info, gettext("Thread created successfully."))
        |> redirect(to: message_path(conn, :show, thread, message))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp maybe_set_cookie(conn, true, ordering),
    do: Plug.Conn.put_resp_cookie(conn, "cf_order", ordering, max_age: 360 * 24 * 60 * 60)

  defp maybe_set_cookie(conn, _, _), do: conn

  defp get_ordering(conn, user) do
    cond do
      present?(conn.params["order"]) ->
        order = conn.params["order"] |> Threads.validated_ordering(conn.assigns[:current_forum])
        {user == nil, order}

      present?(conn.cookies["cf_order"]) && user == nil ->
        order = conn.cookies["order"] |> Threads.validated_ordering(conn.assigns[:current_forum])
        {false, order}

      true ->
        {false, uconf(conn, "sort_threads")}
    end
  end

  # "srt" as in „show read threads“
  defp hide_read_threads?(conn), do: uconf(conn, "hide_read_threads") == "yes" && conn.params["srt"] != "yes"
end
