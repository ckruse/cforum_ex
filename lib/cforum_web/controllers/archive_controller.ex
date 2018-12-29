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
    {:ok, month} = NaiveDateTime.new(String.to_integer(year), Timex.month_to_num(month_name), 1, 0, 0, 0)
    start_date = Timex.beginning_of_month(month)
    end_date = Timex.end_of_month(month)
    page = parse_page(params["p"]) - 1
    limit = uconf(conn, "pagination", :int)

    {count, threads} =
      Threads.list_archived_threads(
        conn.assigns[:current_forum],
        conn.assigns[:visible_forums],
        conn.assigns[:current_user],
        start_date,
        end_date,
        page: page,
        limit: limit,
        view_all: conn.assigns[:view_all],
        message_order: uconf(conn, "sort_messages"),
        use_paging: uconf(conn, "page_messages") == "yes",
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )

    p = paginate(count, per_page: limit, page: page + 1)

    render(conn, "threads.html", threads: threads, page: p, start_date: start_date)
  end

  def allowed?(conn, _, _), do: access_forum?(conn)
end
