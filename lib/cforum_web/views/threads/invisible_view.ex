defmodule CforumWeb.Threads.InvisibleView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("invisible threads")
  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(:index, _), do: "invisible-threads-list"
  def body_classes(:index, _), do: "invisible-threads list"
end
