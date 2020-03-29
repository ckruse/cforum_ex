defmodule CforumWeb.Users.UserView do
  use CforumWeb, :view

  alias Cforum.Tags.Tag
  alias Cforum.ConfigManager

  alias CforumWeb.Paginator
  alias CforumWeb.Sortable

  alias Cforum.Abilities
  alias Cforum.ConfigManager
  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def page_title(:index, _), do: gettext("Users")
  def page_title(:show, assigns), do: gettext("User %{username}", username: assigns[:user].username)

  def page_title(:show_messages, assigns),
    do: gettext("All messages for user %{username}", username: assigns[:user].username)

  def page_title(:show_scores, assigns),
    do: gettext("All scores for user %{username}", username: assigns[:user].username)

  def page_title(:show_votes, assigns), do: gettext("All votes for user %{username}", username: assigns[:user].username)
  def page_title(:update, assigns), do: gettext("Edit profile: %{username}", username: assigns[:user].username)
  def page_title(:edit, assigns), do: page_title(:update, assigns)
  def page_title(:confirm_delete, assigns), do: gettext("Delete user %{username}", username: assigns[:user].username)
  def page_title(:deletion_started, _assigns), do: gettext("Deletion started")

  def page_heading(:index, _), do: gettext("Users")
  def page_heading(:show, assigns), do: gettext("User %{username}", username: assigns[:user].username)

  def page_heading(:show_messages, assigns),
    do: gettext("All messages for user %{username}", username: assigns[:user].username)

  def page_heading(:show_scores, assigns),
    do: gettext("All scores for user %{username}", username: assigns[:user].username)

  def page_heading(:show_votes, assigns),
    do: gettext("All votes for user %{username}", username: assigns[:user].username)

  def page_heading(:update, assigns), do: page_title(:update, assigns)
  def page_heading(:edit, assigns), do: page_heading(:update, assigns)

  def page_heading(:confirm_delete, assigns), do: gettext("Delete user %{username}", username: assigns[:user].username)
  def page_heading(:deletion_started, _assigns), do: gettext("Deletion started")

  def body_id(:index, _), do: "users-index"
  def body_id(:show, _), do: "users-show"
  def body_id(:show_messages, _), do: "users-messages"
  def body_id(:show_scores, _), do: "users-scores"
  def body_id(:show_votes, _), do: "users-votes"
  def body_id(:update, _), do: "users-edit"
  def body_id(:edit, conn), do: body_id(:update, conn)
  def body_id(:confirm_delete, _), do: "users-destroy"
  def body_id(:deletion_started, _), do: "users-destroy-started"

  def body_classes(:index, _), do: "users"
  def body_classes(:show, _), do: "users show"
  def body_classes(:show_messages, _), do: "users messages"
  def body_classes(:show_scores, _), do: "users scores"
  def body_classes(:show_votes, _), do: "users votes"
  def body_classes(:update, _), do: "users edit"
  def body_classes(:edit, conn), do: body_classes(:update, conn)
  def body_classes(:confirm_delete, _), do: "users destroy"
  def body_classes(:deletion_started, _), do: "users destroy started"

  def merge_default_config(setting, options) do
    Enum.reduce(ConfigManager.user_config_keys(), options, fn key, opts ->
      if Map.has_key?(opts, key),
        do: opts,
        else: Map.put(opts, String.to_atom(key), ConfigManager.conf(setting, key))
    end)
  end
end
