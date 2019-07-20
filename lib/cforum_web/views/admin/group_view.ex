defmodule CforumWeb.Admin.GroupView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("administrate groups")
  def page_title(action, _) when action in [:new, :create], do: gettext("new group")

  def page_title(action, assigns) when action in [:edit, :update],
    do: gettext("edit group „%{name}“", name: assigns[:group].name)

  def body_id(:index, _), do: "admin-groups-index"
  def body_id(:new), do: "admin-groups-new"
  def body_id(:create), do: "admin-groups-create"
  def body_id(:edit), do: "admin-groups-edit"
  def body_id(:update), do: "admin-groups-update"

  def body_classes(:index, _), do: "admin groups index"
  def body_classes(:new, _), do: "admin groups new"
  def body_classes(:create, _), do: "admin groups create"
  def body_classes(:edit, _), do: "admin groups edit"
  def body_classes(:update, _), do: "admin groups update"

  def page_heading(action, assigns), do: page_title(action, assigns)
end
