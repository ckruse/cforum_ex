defmodule Cforum.Abilities do
  @moduledoc """
  This module defines all access rights for users in our forum system
  """

  require Logger

  alias Cforum.Accounts.{Settings, Setting}
  alias Cforum.Forums

  @callback allowed?(Plug.Conn.t(), atom(), any()) :: boolean()

  @doc """
  Returns `true` if the user may access the given path, `false` otherwise

  ## Parameters

  - `conn`: the connection struct of the current request
  - `path`: the path to check if the user has access to, e.g. `"users/user"`
  - `action`: the action on the path, e.g. `:index`
  - `args`: additional arguments, e.g. the resource in question
  """
  @spec may?(Plug.Conn.t() | map(), String.t() | atom(), atom(), any()) :: boolean()
  def may?(conn, path, action \\ :index, args \\ nil)

  def may?(%Plug.Conn{} = conn, controller_path, action, resource) when is_bitstring(controller_path) do
    nam =
      controller_path
      |> String.capitalize()
      |> (fn s -> Regex.replace(~r/_(.)/, s, fn _, c -> String.upcase(c) end) end).()
      |> (fn s -> Regex.replace(~r{/(.)}, s, fn _, c -> "." <> String.upcase(c) end) end).()

    controller = String.to_existing_atom("Elixir.CforumWeb.#{nam}Controller")
    may?(conn, controller, action, resource)
  end

  def may?(%Plug.Conn{} = conn, controller_module, action, resource),
    do: controller_module.allowed?(conn, action, resource)

  def may?(%{} = assigns, controller_module, action, resource) do
    conn =
      %Plug.Conn{private: %{phoenix_endpoint: CforumWeb.Endpoint}, assigns: assigns}
      |> maybe_set_confs()

    may?(conn, controller_module, action, resource)
  end

  defp maybe_set_confs(%Plug.Conn{assigns: %{global_config: conf}} = conn) when not is_nil(conf), do: conn

  defp maybe_set_confs(%Plug.Conn{} = conn) do
    settings = Settings.load_relevant_settings(conn.assigns[:current_forum], conn.assigns[:current_user])

    Enum.reduce(settings, conn, fn
      conf = %Setting{user_id: nil, forum_id: nil}, conn -> Plug.Conn.assign(conn, :global_config, conf)
      conf = %Setting{forum_id: nil}, conn -> Plug.Conn.assign(conn, :user_config, conf)
      conf = %Setting{user_id: nil}, conn -> Plug.Conn.assign(conn, :forum_config, conf)
    end)
  end

  alias Cforum.Accounts.Groups
  alias Cforum.Accounts.Users

  alias Cforum.Accounts.ForumGroupPermission
  alias Cforum.Accounts.User
  alias Cforum.Accounts.Badge

  alias Cforum.Forums.Messages

  import Cforum.Helpers

  @doc """
  Returns true if a user is signed in, returns false otherwise

  ## Examples

      iex> signed_in?(conn)
      true
  """
  def signed_in?(conn), do: conn.assigns[:current_user] != nil

  @doc """
  Returns true if the user is an admin user

  ## Parameters

  - conn_or_user: either a `%Plug.Conn{}` struct or a `%Cforum.Accounts.User{}` struct

  ## Examples

      iex> admin?(%User{})
      false

      iex> admin?(%User{admin: true})
      true
  """
  def admin?(conn_or_user)
  def admin?(%Plug.Conn{} = conn), do: admin?(conn.assigns[:current_user])
  def admin?(%User{} = user), do: user.admin
  def admin?(_), do: false

  def badge?(conn_or_user, badge_type)
  def badge?(nil, _), do: false
  def badge?(%Plug.Conn{} = conn, badge_type), do: badge?(conn.assigns[:current_user], badge_type)
  def badge?(%User{} = user, badge_type), do: Users.badge?(user, badge_type)
  def badge?(id, badge_type) when is_number(id), do: Users.badge?(Users.get_user!(id), badge_type)
  def badge?(_, _), do: false

  def accept_allowed?(conn, message) do
    cond do
      admin?(conn) ->
        true

      access_forum?(conn.assigns[:current_user], message.forum_id, :moderate) ->
        true

      signed_in?(conn) && message.user_id == conn.assigns[:current_user].user_id ->
        true

      present?(message.uuid) && present?(conn.cookies["cforum_user"]) && message.uuid == conn.cookies["cforum_user"] ->
        true

      true ->
        false
    end
  end

  def accept?(conn, message),
    do: access_forum?(conn, :write) && !Messages.closed?(message) && accept_allowed?(conn, message)

  @doc """
  Returns true if the user may access the given forum

  ## Parameters

  - nil_conn_or_user: either a `%Plug.Conn{}` struct or a `%Cforum.Accounts.User{}` struct
  - forum: a `Cforum.Forums.Forum{}` struct; the forum to check if the user may access it
  - permission: one of `:read`, `:write` or `:moderate` (the access level). Defaults to `:read`

  ## Examples

      iex> access_forum?(%User{}, %Forum{standard_permission: "read"}, :write)
      false

      iex> access_forum?(%User{}, %Forum{standard_permission: "read})
      true
  """
  def access_forum?(nil_conn_or_user, forum_or_permission \\ :read, permission \\ :read)

  def access_forum?(%Plug.Conn{} = conn, permission, _) when permission in [:read, :write, :moderate],
    do: access_forum?(conn.assigns[:current_user], conn.assigns[:current_forum], permission)

  def access_forum?(%Plug.Conn{} = conn, forum, permission),
    do: access_forum?(conn.assigns[:current_user], forum, permission)

  def access_forum?(user, forum_id, permission) when is_integer(forum_id) or is_bitstring(forum_id),
    do: access_forum?(user, Forums.get_forum!(forum_id), permission)

  def access_forum?(%User{admin: true}, _, _), do: true
  def access_forum?(user, forum, :read), do: access_forum_read?(user, forum)
  def access_forum?(user, forum, :write), do: access_forum_write?(user, forum)
  def access_forum?(user, forum, :moderate), do: access_forum_moderate?(user, forum)
  def access_forum?(_, _, _), do: false

  #
  # read access
  #

  defp access_forum_read?(_, nil), do: true

  defp access_forum_read?(nil, forum),
    do: forum.standard_permission in [ForumGroupPermission.write(), ForumGroupPermission.read()]

  defp access_forum_read?(user, forum) do
    if standard_permission_valid?(forum) do
      true
    else
      permissions = Groups.list_permissions_for_user_and_forum(user, forum)
      !blank?(permissions)
    end
  end

  #
  # write access
  #
  defp access_forum_write?(_, nil), do: true
  defp access_forum_write?(nil, forum), do: forum.standard_permission == ForumGroupPermission.write()

  defp access_forum_write?(user, forum) do
    permissions = Groups.list_permissions_for_user_and_forum(user, forum)

    cond do
      forum.standard_permission in [ForumGroupPermission.write(), ForumGroupPermission.known_write()] ->
        true

      Users.badge?(user, Badge.moderator_tools()) && generally_has_access?(permissions, forum) ->
        true

      Groups.permission?(permissions, [ForumGroupPermission.moderate(), ForumGroupPermission.write()]) ->
        true

      true ->
        false
    end
  end

  #
  # moderator access
  #
  defp access_forum_moderate?(nil, _), do: false
  defp access_forum_moderate?(user, nil), do: Users.badge?(user, Badge.moderator_tools())

  defp access_forum_moderate?(user, forum) do
    permissions = Groups.list_permissions_for_user_and_forum(user, forum)

    if Users.badge?(user, Badge.moderator_tools()) && generally_has_access?(permissions, forum) do
      true
    else
      Groups.permission?(permissions, ForumGroupPermission.moderate())
    end
  end

  defp generally_has_access?(permissions, forum), do: !blank?(permissions) || standard_permission_valid?(forum)

  defp standard_permission_valid?(forum) do
    forum.standard_permission in [
      ForumGroupPermission.read(),
      ForumGroupPermission.write(),
      ForumGroupPermission.known_read(),
      ForumGroupPermission.known_write()
    ]
  end
end
