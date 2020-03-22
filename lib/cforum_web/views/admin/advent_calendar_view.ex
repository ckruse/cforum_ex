defmodule CforumWeb.Admin.AdventCalendarView do
  use CforumWeb, :view

  alias Cforum.Helpers

  alias CforumWeb.ErrorHelpers
  alias CforumWeb.Views.ViewHelpers

  def page_title(action, _) when action in [:index_years], do: gettext("administrate advent calendars")
  def page_title(:index, %{year: year}), do: gettext("administrate advent calendar %{year}", year: year)
  def page_title(action, _) when action in [:new, :create], do: gettext("new advent calendar day")
  def page_title(action, _) when action in [:edit, :update], do: gettext("edit advent calendar day")

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index_years, _), do: "admin-advent-calendars-year-index"
  def body_id(:index, _), do: "admin-advent-calendars-day-index"
  def body_id(:new, _), do: "admin-advent-calendars-new"
  def body_id(:create, _), do: "admin-advent-calendars-create"
  def body_id(:edit, _), do: "admin-advent-calendars-edit"
  def body_id(:update, _), do: "admin-advent-calendars-update"

  def body_classes(:index_years, _), do: "admin advent-calendars index years"
  def body_classes(:index, _), do: "admin advent-calendars index days"
  def body_classes(:new, _), do: "admin advent-calendars new"
  def body_classes(:create, _), do: "admin advent-calendars create"
  def body_classes(:edit, _), do: "admin advent-calendars edit"
  def body_classes(:update, _), do: "admin advent-calendars update"

  def find_day(days, no), do: Enum.find(days, &(&1.date.day == no))
end
