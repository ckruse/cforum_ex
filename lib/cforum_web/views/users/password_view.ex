defmodule CforumWeb.Users.PasswordView do
  use CforumWeb, :view

  def page_title(:new, _), do: gettext("Send password reset instructions")
  def page_title(:create, assigns), do: page_title(:new, assigns)
  def page_title(:edit_reset, _), do: gettext("Reset my password")
  def page_title(:update_reset, assigns), do: page_title(:edit_reset, assigns)
  def page_title(:update, assigns), do: gettext("change password: %{username}", username: assigns[:user].username)
  def page_title(:edit, assigns), do: page_title(:update, assigns)

  def page_heading(:new, assigns), do: page_title(:new, assigns)
  def page_heading(:create, assigns), do: page_title(:new, assigns)
  def page_heading(:edit_reset, assigns), do: page_title(:edit_reset, assigns)
  def page_heading(:update_reset, assigns), do: page_title(:update_reset, assigns)
  def page_heading(:update, assigns), do: page_title(:update, assigns)
  def page_heading(:edit, assigns), do: page_heading(:update, assigns)

  def body_id(:update, _), do: "users-password"
  def body_id(:edit, conn), do: body_id(:update, conn)

  def body_classes(:update, _), do: "users password"
  def body_classes(:edit, conn), do: body_classes(:update, conn)
end
