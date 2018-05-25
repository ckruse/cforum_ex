defmodule CforumWeb.ArchiveView do
  use CforumWeb, :view

  def page_title(:years, _), do: gettext("archive")
  def page_title(:months, assigns), do: gettext("archive: %{year}", year: assigns[:year])

  def page_title(:threads, assigns),
    do: gettext("archive: %{month}", month: Timex.format!(assigns[:start_date], "%B %Y", :strftime))

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:years, _), do: "archive-years"
  def body_id(:months, _), do: "archive-months"
  def body_id(:threads, _), do: "archive-threads"

  def body_classes(:years, _), do: "archive years"
  def body_classes(:months, _), do: "archive months"
  def body_classes(:threads, _), do: "archive threads"
end
