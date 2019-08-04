defmodule CforumWeb.PageView do
  use CforumWeb, :view

  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def page_title(:help, _), do: gettext("help & support")
  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:help, _), do: "forum-help"
  def body_classes(:help, _), do: "help"
end
