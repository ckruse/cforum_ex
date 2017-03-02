defmodule Cforum.Users.RegistrationView do
  use Cforum.Web, :view

  def page_title(:new, _), do: gettext("register")
  def page_heading(:new, _), do: gettext("register")
  def body_id(:new, _), do: "registrations-new"
  def body_classes(:new, _), do: "registrations new"
end
