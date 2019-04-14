defmodule CforumWeb.ArchiveController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads

  def years(conn, _params) do
    years = Threads.list_archive_years(conn.assigns[:current_forum], conn.assigns[:visible_forums])
    render(conn, "years.html", years: years)
  end

  def months(conn, %{"year" => year}) do
    months = Threads.list_archive_months(conn.assigns[:current_forum], conn.assigns[:visible_forums], year)
    render(conn, "months.html", months: months, year: year)
  end

  def threads(conn, %{"year" => year, "month" => month_name} = params) do
    with {:ok, month} <- NaiveDateTime.new(String.to_integer(year), Timex.month_to_num(month_name), 1, 0, 0, 0) do
      start_date = Timex.beginning_of_month(month)
      end_date = Timex.end_of_month(month)
      page = parse_page(params["p"]) - 1
      limit = uconf(conn, "pagination", :int)

      threads =
        conn.assigns[:current_forum]
        |> Threads.list_archived_threads(conn.assigns[:visible_forums], start_date, end_date)
        |> Threads.reject_deleted_threads(conn.assigns[:view_all])
        |> Threads.apply_user_infos(conn.assigns[:current_user],
          close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
          open_close_default_state: uconf(conn, "open_close_default")
        )
        |> Threads.apply_highlights(conn)

      count = length(threads)

      threads =
        threads
        |> Threads.sort_threads(uconf(conn, "sort_threads"))
        |> Threads.paged_thread_list(page, limit)
        |> Threads.build_message_trees(uconf(conn, "sort_messages"))

      p = paginate(count, per_page: limit, page: page + 1)

      render(conn, "threads.html", threads: threads, page: p, start_date: start_date)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(CforumWeb.ErrorView)
        |> render("404.html")
    end
  end

  def allowed?(conn, _, _), do: Abilities.access_forum?(conn)
end
