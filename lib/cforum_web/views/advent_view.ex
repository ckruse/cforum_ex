defmodule CforumWeb.AdventView do
  use CforumWeb, :view

  alias Cforum.Helpers

  def page_title(:index, _), do: gettext("advent calendars")
  def page_title(:show, %{year: year}), do: gettext("advent calendar %{year}", year: year)
  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "advent-calendar-index"
  def body_id(:show, _), do: "advent-calendar-day-index"

  def body_classes(:index, _), do: "advent-calendar index"
  def body_classes(:show, %{year: year}), do: "advent-calendar index day year-#{year}"

  def find_day(days, no, today) do
    day = Enum.find(days, &(&1.date.day == no))

    cond do
      day == nil -> nil
      Timex.before?(day.date, today) || Timex.equal?(day.date, today, :day) -> day
      true -> nil
    end
  end

  def past?(year, day_no, today) when is_bitstring(year), do: past?(Helpers.to_int(year), day_no, today)

  def past?(year, day_no, today) do
    cond do
      year < today.year -> true
      year > today.year -> false
      today.month == 12 && day_no <= today.day -> true
      true -> false
    end
  end
end
