defmodule CforumWeb.Users.RegistrationView do
  use CforumWeb, :view

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  def page_title(action, _) when action in [:new, :create], do: gettext("register")
  def page_title(:confirm, _), do: gettext("Confirm my account")

  def page_heading(action, _) when action in [:new, :create], do: gettext("register")
  def page_heading(:confirm, _), do: gettext("Confirm my account")

  def body_id(action, _), do: "registrations-#{action}"
  def body_classes(action, _), do: "registrations #{action}"
end
