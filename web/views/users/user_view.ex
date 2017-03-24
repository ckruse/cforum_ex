defmodule Cforum.Users.UserView do
  use Cforum.Web, :view

  def page_title(:index, _), do: gettext("Users")
  def page_title(:show, assigns), do: gettext("User %{username}", username: assigns[:user].username)
  def page_title(:show_messages, assigns), do: gettext("All messages for user %{username}", username: assigns[:user].username)
  def page_title(:show_scores, assigns), do: gettext("All scores for user %{username}", username: assigns[:user].username)
  def page_title(:show_votes, assigns), do: gettext("All votes for user %{username}", username: assigns[:user].username)

  def page_heading(:index, _), do: gettext("Users")
  def page_heading(:show, assigns), do: gettext("User %{username}", username: assigns[:user].username)
  def page_heading(:show_messages, assigns), do: gettext("All messages for user %{username}", username: assigns[:user].username)
  def page_heading(:show_scores, assigns), do: gettext("All scores for user %{username}", username: assigns[:user].username)
  def page_heading(:show_votes, assigns), do: gettext("All votes for user %{username}", username: assigns[:user].username)

  def body_id(:index, _), do: "forums-index"
  def body_id(:show, _), do: "users-show"
  def body_id(:show_messages, _), do: "users-messages"
  def body_id(:show_scores, _), do: "users-scores"
  def body_id(:show_votes, _), do: "users-votes"

  def body_classes(:index, _), do: "forums"
  def body_classes(:show, _), do: "users show"
  def body_classes(:show_messages, _), do: "users messages"
  def body_classes(:show_scores, _), do: "users scores"
  def body_classes(:show_votes, _), do: "users votes"
end
