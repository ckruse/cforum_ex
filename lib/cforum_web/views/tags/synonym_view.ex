defmodule CforumWeb.Tags.SynonymView do
  use CforumWeb, :view

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  def page_title(action, assigns) when action in [:edit, :update] do
    gettext(
      "edit tag synonym “%{synonym}” for tag “%{tag}”",
      synonym: assigns[:synonym].synonym,
      tag: assigns[:tag].tag_name
    )
  end

  def page_title(action, assigns) when action in [:new, :create],
    do: gettext("create new tag synonym for tag “%{tag}”", tag: assigns[:tag].tag_name)

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:new, _), do: "tag-synonym-new"
  def body_id(:create, _), do: "tag-synonym-create"
  def body_id(:edit, _), do: "tag-synonym-edit"
  def body_id(:update, _), do: "tag-synonym-update"

  def body_classes(:new, _), do: "tag synonym new"
  def body_classes(:create, _), do: "tag synonym create"
  def body_classes(:edit, assigns), do: "tag synonym edit #{assigns[:tag].slug}"
  def body_classes(:update, assigns), do: "tag synonym update #{assigns[:tag].slug}"
end
