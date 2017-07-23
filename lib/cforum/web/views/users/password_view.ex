defmodule Cforum.Web.Users.PasswordView do
  use Cforum.Web, :view

  def page_title(:update, assigns), do: gettext("change password: %{username}", username: assigns[:user].username)
  def page_title(:edit, assigns), do: page_title(:update, assigns)

  def page_heading(:update, assigns), do: page_title(:update, assigns)
  def page_heading(:edit, assigns), do: page_heading(:update, assigns)

  def body_id(:update, _), do: "users-password"
  def body_id(:edit, conn), do: body_id(:update, conn)

  def body_classes(:update, _), do: "users password"
  def body_classes(:edit, conn), do: body_classes(:update, conn)
end
