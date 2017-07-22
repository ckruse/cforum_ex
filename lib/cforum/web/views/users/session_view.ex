defmodule Cforum.Web.Users.SessionView do
  use Cforum.Web, :view

  def page_title(:index, _), do: gettext("Login")
  def body_id(:index, _), do: "session-new"
  def body_classes(:index, _), do: "session new"
end
