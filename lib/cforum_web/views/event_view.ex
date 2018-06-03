defmodule CforumWeb.EventView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("events")
  def page_title(:show, %{event: event}), do: event.name

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "events-index"
  def body_id(:show, _), do: "events-show"

  def body_classes(:index, _), do: "events index"
  def body_classes(:show, _), do: "events show"
end
