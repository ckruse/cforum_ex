defmodule CforumWeb.AdventController do
  use CforumWeb, :controller

  alias Cforum.AdventCalendars

  def index(conn, _params) do
    years = AdventCalendars.list_years()
    render(conn, "index.html", years: years)
  end

  def show(conn, %{"year" => year}) do
    if !Regex.match?(~r/^\d+$/, year),
      do: raise(Cforum.Errors.NotFoundError, conn: conn)

    advent_calendar_days = AdventCalendars.list_advent_calendar_days(year)
    render(conn, "show.html", advent_calendar_days: advent_calendar_days, year: year, today: Timex.today())
  end

  def allowed?(_, _, _), do: true
end
