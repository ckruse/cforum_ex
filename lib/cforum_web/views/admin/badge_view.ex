defmodule CforumWeb.Admin.BadgeView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("administrate badges")
  def page_title(action, _) when action in [:new, :create], do: gettext("new badge")

  def page_title(action, assigns) when action in [:edit, :update],
    do: gettext("edit badge „%{name}“", name: assigns[:badge].name)

  def body_id(:index, _), do: "admin-badges-index"
  def body_id(:new), do: "admin-badges-new"
  def body_id(:create), do: "admin-badges-create"
  def body_id(:edit), do: "admin-badges-edit"
  def body_id(:update), do: "admin-badges-update"

  def body_classes(:index, _), do: "admin badges index"
  def body_classes(:new, _), do: "admin badges new"
  def body_classes(:create, _), do: "admin badges create"
  def body_classes(:edit, _), do: "admin badges edit"
  def body_classes(:update, _), do: "admin badges update"

  def page_heading(action, assigns), do: page_title(action, assigns)

  def medal_type_options(), do: Enum.map(Cforum.Accounts.Badge.badge_medal_types(), &{VHelpers.l10n_medal_type(&1), &1})
  def badge_type_options(), do: Enum.map(Cforum.Accounts.Badge.badge_types(), &{VHelpers.l10n_badge_type(&1), &1})
end
