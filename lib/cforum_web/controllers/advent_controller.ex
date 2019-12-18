defmodule CforumWeb.AdventController do
  use CforumWeb, :controller

  alias Cforum.AdventCalendars

  def index(conn, %{"year" => year}) do
    advent_calendar_days = AdventCalendars.list_advent_calendar_days(year)
    render(conn, "index.html", advent_calendar_days: advent_calendar_days, year: year, today: Timex.today())
  end

  def allowed?(_, _, _), do: true
end
