defmodule CforumWeb.BlogController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.ConfigManager

  alias CforumWeb.Paginator

  def index(conn, params) do
    page = Paginator.parse_page(params["p"]) - 1
    limit = 5

    threads = thread_list(conn)
    all_threads_count = length(threads)

    threads =
      threads
      |> Threads.sort_threads("descending")
      |> Threads.paged_thread_list(page, limit, true)
      |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))

    p = Paginator.paginate(all_threads_count, per_page: limit, page: page + 1)

    render(conn, "index.html", threads: threads, all_threads_count: all_threads_count, page: p, order: "descending")
  end

  defp thread_list(conn) do
    conn.assigns[:current_forum]
    |> Threads.list_threads(conn.assigns[:visible_forums])
    |> Threads.reject_deleted_threads(conn.assigns[:view_all])
    |> Threads.reject_invisible_threads(conn.assigns[:current_user], conn.assigns[:view_all])
    |> Threads.apply_user_infos(conn.assigns[:current_user])
  end

  def allowed?(_, _, _), do: true
end
