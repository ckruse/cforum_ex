defmodule CforumWeb.SearchView do
  use CforumWeb, :view

  alias CforumWeb.Paginator

  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  def page_title(:show, _), do: gettext("forum search")
  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(_, _), do: "search"
  def body_classes(_, _), do: "search"

  def checked?(section, form) do
    values =
      Enum.map(input_value(form, :sections), fn s ->
        if is_binary(s) && Regex.match?(~r/^\d+$/, s),
          do: String.to_integer(s),
          else: s
      end)

    section.search_section_id in values
  end

  def should_show_title?(nil), do: false
  def should_show_title?(""), do: false
  def should_show_title?(str), do: String.contains?(str, "<b>")
end
