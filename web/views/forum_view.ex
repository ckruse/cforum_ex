defmodule Cforum.ForumView do
  use Cforum.Web, :view

  def page_title(:index, _), do: gettext("Forums")
  def body_id(:index, _), do: "forums-index"
  def body_classes(:index, _), do: "forums"
end
