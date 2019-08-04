defmodule CforumWeb.Views.ViewHelpers.RelativeTime do
  @moduledoc """
  Provides functions to convert a time period to a relative text, e.g. „a year ago“
  """

  import CforumWeb.Gettext

  @doc """
  Generates a relative time text, e.g. "less than 5 seconds" or "about an hour".
  `time` may be a `%DateTime{}` or the number of seconds for the duration.
  """
  def relative_time(%DateTime{} = time), do: relative_time(Timex.diff(Timex.now(), time, :seconds))
  def relative_time(%NaiveDateTime{} = time), do: relative_time(Timex.diff(Timex.now(), time, :seconds))

  def relative_time(seconds) do
    minutes = round(seconds / 60)
    time_as_relative_text(minutes, seconds)
  end

  defp time_as_relative_text(minutes, seconds) when minutes in 0..1 do
    case seconds do
      seconds when seconds in 0..4 ->
        gettext("less than 5 seconds")

      seconds when seconds in 5..9 ->
        gettext("less than 10 seconds")

      seconds when seconds in 10..19 ->
        gettext("less than 20 seconds")

      seconds when seconds in 20..39 ->
        gettext("half a minute")

      seconds when seconds in 40..59 ->
        gettext("less than a minute")

      _ ->
        gettext("about 1 minute")
    end
  end

  defp time_as_relative_text(minutes, _) when minutes in 2..44,
    do: gettext("less than %{minutes} minutes", minutes: rounded_minutes(minutes))

  defp time_as_relative_text(minutes, _) when minutes in 45..89, do: gettext("about an hour")

  defp time_as_relative_text(minutes, _) when minutes in 90..1439,
    do: gettext("about %{hours} hours", hours: round(minutes / 60))

  defp time_as_relative_text(minutes, _) when minutes in 1440..2519, do: gettext("a day")

  defp time_as_relative_text(minutes, _) when minutes in 2_520..43_199,
    do: gettext("%{days} days", days: round(minutes / 1440))

  defp time_as_relative_text(minutes, _) when minutes in 43_200..86_399, do: gettext("about 1 month")

  defp time_as_relative_text(minutes, _) when minutes in 86_400..525_599,
    do: gettext("%{months} months", months: round(minutes / 43_200))

  defp time_as_relative_text(minutes, _) when minutes in 525_600..1_051_199, do: gettext("1 year")
  defp time_as_relative_text(minutes, _), do: gettext("%{years} years", years: round(minutes / 525_600))

  defp rounded_minutes(no) do
    result = trunc(Float.floor((no + 5) / 5) * 5)

    if result < 5,
      do: 5,
      else: result
  end
end
