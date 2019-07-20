defmodule CforumWeb.ArchiveView do
  use CforumWeb, :view

  defp forum_name(%{current_forum: forum}) when not is_nil(forum), do: forum.name
  defp forum_name(_), do: gettext("all forums")

  def page_title(:years, assigns), do: gettext("archive – %{forum}", forum: forum_name(assigns))

  def page_title(:months, assigns),
    do: gettext("archive: %{year} – %{forum}", year: assigns[:year], forum: forum_name(assigns))

  def page_title(:threads, assigns) do
      gettext("archive: %{month} – %{forum}",
        month: Timex.format!(assigns[:start_date], "%B %Y", :strftime),
        forum: forum_name(assigns)
      )
  end

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:years, _), do: "archive-years"
  def body_id(:months, _), do: "archive-months"
  def body_id(:threads, _), do: "archive-threads"

  def body_classes(:years, _), do: "archive years"
  def body_classes(:months, _), do: "archive months"
  def body_classes(:threads, _), do: "archive threads"

  def year_title([]), do: ""
  def year_title([%NaiveDateTime{} = year | _]), do: to_string(year.year)

  def month_link_title(month) do
    month_name = Timex.format!(month, "%B", :strftime)

    [
      String.slice(month_name, 0..2),
      {:safe, "<span class=\"full-month\">"},
      String.slice(month_name, 3..-1),
      {:safe, "</span>"}
    ]
  end

  def months_for_year(year) do
    year_no = List.first(year).year
    for m <- 1..12, do: {%Date{year: year_no, month: m, day: 1}, Enum.find(year, &(&1.month == m)) != nil}
  end
end
