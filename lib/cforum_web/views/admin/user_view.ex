defmodule CforumWeb.Admin.UserView do
  use CforumWeb, :view

  alias CforumWeb.Paginator
  alias CforumWeb.Sortable

  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  def page_title(:index, _), do: gettext("administrate users")
  def page_title(action, _) when action in [:new, :create], do: gettext("new user")

  def page_title(action, assigns) when action in [:edit, :update],
    do: gettext("edit user „%{name}“", name: assigns[:user].username)

  def body_id(:index, _), do: "admin-users-index"
  def body_id(:new, _), do: "admin-users-new"
  def body_id(:create, _), do: "admin-users-create"
  def body_id(:edit, _), do: "admin-users-edit"
  def body_id(:update, _), do: "admin-users-update"

  def body_classes(:index, _), do: "admin users index"
  def body_classes(:new, _), do: "admin users new"
  def body_classes(:create, _), do: "admin users create"
  def body_classes(:edit, _), do: "admin users edit"
  def body_classes(:update, _), do: "admin users update"

  def page_heading(action, assigns), do: page_title(action, assigns)
end
