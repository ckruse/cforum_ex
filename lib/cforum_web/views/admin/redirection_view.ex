defmodule CforumWeb.Admin.RedirectionView do
  use CforumWeb, :view

  alias CforumWeb.Paginator
  alias CforumWeb.Sortable

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  def page_title(:index, _), do: gettext("administrate redirections")
  def page_title(action, _) when action in [:new, :create], do: gettext("new redirection")
  def page_title(action, _) when action in [:edit, :update], do: gettext("edit redirection")

  def body_id(:index, _), do: "admin-redirections-index"
  def body_id(:new, _), do: "admin-redirections-new"
  def body_id(:create, _), do: "admin-redirections-create"
  def body_id(:edit, _), do: "admin-redirections-edit"
  def body_id(:update, _), do: "admin-redirections-update"

  def body_classes(:index, _), do: "admin redirections index"
  def body_classes(:new, _), do: "admin redirections new"
  def body_classes(:create, _), do: "admin redirections create"
  def body_classes(:edit, _), do: "admin redirections edit"
  def body_classes(:update, _), do: "admin redirections update"

  def page_heading(action, assigns), do: page_title(action, assigns)
end
