defmodule CforumWeb.RedirectorView do
  use CforumWeb, :view

  def page_title(_, _), do: gettext("found multiple threads with this thread id")

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(_, _), do: "threads-legacy-redirect-to-thread"

  def body_classes(_, _), do: "threads legacy redirect-to-thread"
end
