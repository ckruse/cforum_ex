defmodule CforumWeb.ForumView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("Forums")
  def body_id(:index, _), do: "forums-index"
  def body_classes(:index, _), do: "forums"
end
