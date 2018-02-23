defmodule CforumWeb.Messages.InterestingView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("messages marked as interesting")
  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(:index, _), do: "interesting-messages-list"
  def body_classes(:index, _), do: "interesting-messages list"
end
