defmodule Cforum.Web.Admin.ForumView do
  use Cforum.Web, :view

  def page_title(_, _), do: "Foo"
  def body_id(_, _), do: ""
  def body_classes(_, _), do: ""
end
