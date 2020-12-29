defmodule CforumWeb.BlogController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.ConfigManager

  alias CforumWeb.Paginator
  alias CforumWeb.Router.Helpers, as: Routes

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

  def old_rss(conn, _),
    do: redirect(conn, to: Routes.blog_path(conn, :index_rss))

  def index_atom(conn, _) do
    threads = feed_thread_list(conn)
    render(conn, "index.atom", threads: threads)
  end

  def index_rss(conn, _) do
    threads = feed_thread_list(conn)
    render(conn, "index.rss", threads: threads)
  end

  defp thread_list(conn) do
    conn.assigns[:current_forum]
    |> Threads.list_threads(conn.assigns[:visible_forums])
    |> Threads.reject_deleted_threads(conn.assigns[:view_all])
    |> Threads.reject_invisible_threads(conn.assigns[:current_user], conn.assigns[:view_all])
    |> Threads.apply_user_infos(conn.assigns[:current_user])
  end

  defp feed_thread_list(conn) do
    user = conn.assigns[:current_user]

    conn.assigns[:current_forum]
    |> Threads.list_threads(conn.assigns[:visible_forums])
    |> Threads.reject_deleted_threads(conn.assigns[:view_all], true)
    |> Threads.reject_invisible_threads(user, conn.assigns[:view_all])
    |> Threads.apply_user_infos(user, omit: [:open_close, :subscriptions, :interesting])
    |> Threads.apply_highlights(conn)
    |> Threads.sort_threads("descending")
    |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))
  end

  def allowed?(_, _, _), do: true
end
