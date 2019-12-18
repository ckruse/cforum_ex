defmodule CforumWeb.AdventView do
  use CforumWeb, :view

  alias Cforum.Helpers

  def page_title(:index, %{year: year}), do: gettext("advent calendar %{year}", year: year)
  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "advent-calendar-day-index"

  def body_classes(:index, %{year: year}), do: "advent-calendar index day year-#{year}"

  def find_day(days, no) do
    day = Enum.find(days, &(&1.date.day == no))
    today = Timex.today()

    cond do
      day == nil -> nil
      Timex.before?(day.date, today) || Timex.equal?(day.date, today) -> day
      true -> nil
    end
  end

  def past?(year, day_no, today) do
    cond do
      year < today.year -> true
      today.month == 12 && day_no <= today.day -> true
      true -> false
    end
  end
end
