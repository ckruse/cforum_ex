defmodule CforumWeb.SearchView do
  use CforumWeb, :view

  def page_title(:show, _), do: gettext("forum search")
  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(_, _), do: "search"
  def body_classes(_, _), do: "search"

  def checked?(section, form), do: section.search_section_id in form.data.sections

  def should_show_title?(nil), do: false
  def should_show_title?(""), do: false
  def should_show_title?(str), do: String.contains?(str, "<b>")

  def should_show_desc?(result) do
    !should_show_title?(result.headline_author) && !should_show_title?(result.headline_title) &&
      !should_show_title?(result.headline_all) && !should_show_title?(result.headline_content)
  end
end
