defmodule CforumWeb.Admin.RedirectionView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("administrate redirections")
  def page_title(action, _) when action in [:new, :create], do: gettext("new redirection")
  def page_title(action, _) when action in [:edit, :update], do: gettext("edit redirection")

  def body_id(:index, _), do: "admin-redirections-index"
  def body_id(:new), do: "admin-redirections-new"
  def body_id(:create), do: "admin-redirections-create"
  def body_id(:edit), do: "admin-redirections-edit"
  def body_id(:update), do: "admin-redirections-update"

  def body_classes(:index, _), do: "admin redirections index"
  def body_classes(:new, _), do: "admin redirections new"
  def body_classes(:create, _), do: "admin redirections create"
  def body_classes(:edit, _), do: "admin redirections edit"
  def body_classes(:update, _), do: "admin redirections update"

  def page_heading(action, assigns), do: page_title(action, assigns)
end
