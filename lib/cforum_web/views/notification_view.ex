defmodule CforumWeb.NotificationView do
  use CforumWeb, :view

  alias CforumWeb.Paginator
  alias CforumWeb.Sortable

  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def page_title(:index, _), do: gettext("Notifications")
  def page_heading(:index, _), do: page_title(:index, nil)
  def body_id(:index, _), do: "notifications-index"
  def body_classes(:index, _), do: "notifications"
end
