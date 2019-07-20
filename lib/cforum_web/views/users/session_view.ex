defmodule CforumWeb.Users.SessionView do
  use CforumWeb, :view

  def page_title(_, _), do: gettext("Login")
  def body_id(_, _), do: "session-new"
  def body_classes(_, _), do: "session new"
end
