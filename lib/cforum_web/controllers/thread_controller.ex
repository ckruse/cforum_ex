defmodule CforumWeb.ThreadController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads

  import Cforum.ConfigManager

  def index(conn, params) do
    page = if blank?(params[:p]) || String.to_integer(params[:p]) <= 0,
             do: 0,
             else: String.to_integer(params[:p])

    limit = String.to_integer(uconf(conn, "pagination"))
    user = conn.assigns[:current_user]
    {set_order_cookie, ordering} = get_ordering(conn, user)

    ordering = if Enum.member?(~w(ascending descending newest-first), ordering),
                 do: ordering,
                 else: "newest-first"

    {all_threads_count, threads} = Threads
                                     .list_threads(conn.assigns[:current_forum], conn.assigns[:visible_forums],
                                                   user, page: page, limit: limit, order: ordering,
                                                   view_all: conn.assigns[:view_all],
                                                   hide_read_threads: uconf(conn, "hide_read_threads") == "yes" && conn.params["srt"] != "yes",
                                                   only_wo_answer: conn.params["only_wo_answer"] != nil,
                                                   message_order: uconf(conn, "sort_messages"), use_paging: uconf(conn, "page_messages") == "yes")

    if set_order_cookie,
      do: Plug.Conn.put_resp_cookie(conn, "cf_order", ordering, max_age: 360 * 24 * 60 * 60),
      else: conn
    |> render("index.html", threads: threads, all_threads_count: all_threads_count)
  end

  defp get_ordering(conn, user) do
    cond do
      conn.params["order"] != "" && conn.params["order"] != nil ->
        {user == nil, conn.params["order"]}

      conn.cookies["cf_order"] != "" && conn.cookies["cf_order"] != nil && user == nil ->
        {false, conn.cookies["order"]}

      true ->
        {false, uconf(conn, "sort_threads")}
    end
  end
end
