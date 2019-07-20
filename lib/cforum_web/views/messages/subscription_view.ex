defmodule CforumWeb.Messages.SubscriptionView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("subscribed messages")
  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(:index, _), do: "subscribed-messages-list"
  def body_classes(:index, _), do: "subscribed-messages list"
end
