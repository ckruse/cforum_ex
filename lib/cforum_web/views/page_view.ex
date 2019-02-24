defmodule CforumWeb.PageView do
  use CforumWeb, :view

  def page_title(:help, _), do: gettext("help & support")
  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:help, _), do: "forum-help"
  def body_classes(:help, _), do: "help"

  def additional_js(:help, assigns), do: Routes.static_path(assigns[:conn], "/js/help.js")
end
