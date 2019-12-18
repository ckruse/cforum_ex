defmodule CforumWeb.Admin.AdventCalendarController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.AdventCalendars
  alias Cforum.AdventCalendars.Day
  alias CforumWeb.Router.Helpers, as: Routes

  def index_years(conn, _params) do
    years = AdventCalendars.list_years()
    render(conn, "index_years.html", years: years)
  end

  def index(conn, %{"year" => year}) do
    advent_calendar_days = AdventCalendars.list_advent_calendar_days(year)
    render(conn, "index.html", advent_calendar_days: advent_calendar_days, year: year)
  end

  def new(conn, _params) do
    changeset = AdventCalendars.change_day(%Day{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"day" => day_params}) do
    case AdventCalendars.create_day(day_params) do
      {:ok, day} ->
        conn
        |> put_flash(:info, gettext("Advent calendar day created successfully."))
        |> redirect(to: Routes.admin_advent_calendar_path(conn, :index, day.date.year))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    day = AdventCalendars.get_day!(id)
    changeset = AdventCalendars.change_day(day)
    render(conn, "edit.html", day: day, changeset: changeset)
  end

  def update(conn, %{"id" => id, "day" => day_params}) do
    day = AdventCalendars.get_day!(id)

    case AdventCalendars.update_day(day, day_params) do
      {:ok, day} ->
        conn
        |> put_flash(:info, gettext("Advent calendar day updated successfully."))
        |> redirect(to: Routes.admin_advent_calendar_path(conn, :index, day.date.year))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", day: day, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    day = AdventCalendars.get_day!(id)
    {:ok, _day} = AdventCalendars.delete_day(day)

    conn
    |> put_flash(:info, gettext("Advent calendar day deleted successfully."))
    |> redirect(to: Routes.admin_advent_calendar_path(conn, :index_years))
  end

  def allowed?(conn, _, _), do: Abilities.admin?(conn)
end
