defmodule CforumWeb.ArchiveView do
  use CforumWeb, :view

  def page_title(:years, _), do: gettext("archive")
  def page_title(:months, assigns), do: gettext("archive: %{year}", year: assigns[:year])

  def page_title(:postings, assigns),
    do: gettext("archive: %{month}", year: Timex.format!(assigns[:year], "%B %Y", :strftime))

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:years, _), do: "archive-years"
  def body_id(:months, _), do: "archive-months"
  def body_id(:postings, _), do: "archive-postings"

  def body_classes(:years, _), do: "archive years"
  def body_classes(:months, _), do: "archive months"
  def body_classes(:postings, _), do: "archive postings"
end
