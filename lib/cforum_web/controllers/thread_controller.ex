defmodule CforumWeb.ThreadController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads

  def index(conn, params) do
    page = parse_page(params[:p]) - 1
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
        use_paging: uconf(conn, "page_messages") == "yes"
      )

    conn
    |> maybe_set_cookie(set_order_cookie, ordering)
    |> render("index.html", threads: threads, all_threads_count: all_threads_count)
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
