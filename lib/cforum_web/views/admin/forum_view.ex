defmodule CforumWeb.Admin.ForumView do
  use CforumWeb, :view

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  def page_title(:index, _), do: gettext("administrate forums")
  def page_title(action, _) when action in [:new, :create], do: gettext("new forum")

  def page_title(action, assigns) when action in [:edit, :update],
    do: gettext("edit forum „%{name}“", name: assigns[:forum].name)

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "admin-forums-index"
  def body_id(:new, _), do: "admin-forums-new"
  def body_id(:create, _), do: "admin-forums-create"
  def body_id(:edit, _), do: "admin-forums-edit"
  def body_id(:update, _), do: "admin-forums-update"

  def body_classes(:index, _), do: "admin forums index"
  def body_classes(:new, _), do: "admin forums new"
  def body_classes(:create, _), do: "admin forums create"
  def body_classes(:edit, _), do: "admin forums edit"
  def body_classes(:update, _), do: "admin forums update"

  def l10n_permission("read"), do: gettext("read")
  def l10n_permission("write"), do: gettext("write")
  def l10n_permission("known-read"), do: gettext("known-read")
  def l10n_permission("known-write"), do: gettext("known-write")
  def l10n_permission("private"), do: gettext("private")
end
