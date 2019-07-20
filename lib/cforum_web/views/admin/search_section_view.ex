defmodule CforumWeb.Admin.SearchSectionView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("administrate search sections")
  def page_title(action, _) when action in [:new, :create], do: gettext("new search section")

  def page_title(action, assigns) when action in [:edit, :update],
    do: gettext("edit search section „%{name}“", name: assigns[:section].name)

  def body_id(:index, _), do: "admin-search-sections-index"
  def body_id(:new), do: "admin-search-sections-new"
  def body_id(:create), do: "admin-search-sections-create"
  def body_id(:edit), do: "admin-search-sections-edit"
  def body_id(:update), do: "admin-search-sections-update"

  def body_classes(:index, _), do: "admin search-sections index"
  def body_classes(:new, _), do: "admin search-sections new"
  def body_classes(:create, _), do: "admin search-sections create"
  def body_classes(:edit, _), do: "admin search-sections edit"
  def body_classes(:update, _), do: "admin search-sections update"

  def page_heading(action, assigns), do: page_title(action, assigns)
end
