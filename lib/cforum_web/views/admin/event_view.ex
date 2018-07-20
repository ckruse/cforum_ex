defmodule CforumWeb.Admin.EventView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("administrate events")
  def page_title(action, _) when action in [:new, :create], do: gettext("new event")

  def page_title(action, assigns) when action in [:edit, :update],
    do: gettext("edit event %{name}", name: assigns[:event].name)

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "admin-events-index"
  def body_id(action, _) when action in [:new, :create], do: "admin-events-new"
  def body_id(action, _) when action in [:edit, :update], do: "admin-events-edit"

  def body_classes(:index, _), do: "admin events index"
  def body_classes(action, _) when action in [:new, :create], do: "admin events new"
  def body_classes(action, _) when action in [:edit, :update], do: "admin events edit"
end
