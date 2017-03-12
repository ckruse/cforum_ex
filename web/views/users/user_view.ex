defmodule Cforum.Users.UserView do
  use Cforum.Web, :view

  def page_title(:index, _), do: gettext("Users")
  def page_heading(:index, _), do: gettext("Users")
  def body_id(:index, _), do: "forums-index"
  def body_classes(:index, _), do: "forums"
end
