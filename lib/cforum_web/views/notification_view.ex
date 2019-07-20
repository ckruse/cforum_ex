defmodule CforumWeb.NotificationView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("Notifications")
  def page_heading(:index, _), do: page_title(:index, nil)
  def body_id(:index, _), do: "notifications-index"
  def body_classes(:index, _), do: "notifications"
end
