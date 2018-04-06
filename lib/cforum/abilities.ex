defmodule Cforum.Abilities do
  @moduledoc """
  This module defines all access rights for users in our forum system
  """

  require Logger

  alias Cforum.Accounts.User

  @doc """
  Returns `true` if the user may access the given path, `false` otherwise

  ## Parameters

  - `conn`: the connection struct of the current request
  - `path`: the path to check if the user has access to, e.g. `"users/user"`
  - `action`: the action on the path, e.g. `:index`
  - `args`: additional arguments, e.g. the resource in question
  """
  def may?(conn, path, action \\ :index, args \\ nil)

  def may?(conn, "users/user", :update, resource) do
    cuser = conn.assigns[:current_user]
    uid = if resource != nil, do: resource.user_id, else: String.to_integer(conn.params["user_id"] || conn.params["id"])
    cuser != nil && (admin?(cuser) || uid == cuser.user_id)
  end

  def may?(conn, "users/user", :edit, resource), do: may?(conn, "users/user", :update, resource)
  def may?(conn, "users/user", :delete, resource), do: may?(conn, "users/user", :update, resource)
  def may?(conn, "users/user", :confirm_delete, resource), do: may?(conn, "users/user", :delete, resource)

  def may?(conn, "users/password", _, resource), do: may?(conn, "users/user", :update, resource)

  def may?(conn, "users/user", :show_votes, resource) do
    cuser = conn.assigns[:current_user]
    uid = if resource != nil, do: resource.user_id, else: String.to_integer(conn.params["id"])
    cuser != nil && uid == cuser.user_id
  end

  def may?(_conn, "cite", action, _) when action in [:index, :show, :new, :create], do: true
  def may?(conn, "cite", action, _) when action not in [:index, :show, :new, :create], do: admin?(conn)
  def may?(conn, "cite/vote", :vote, _), do: signed_in?(conn)

  # TODO implement proper rights
  def may?(_conn, "message", _, _), do: true

  def may?(conn, "messages/mark_read", _, _), do: signed_in?(conn)
  def may?(conn, "messages/subscription", _, _), do: signed_in?(conn)
  def may?(conn, "messages/interesting", _, _), do: signed_in?(conn)
  def may?(conn, "threads/invisible", _, _), do: signed_in?(conn)
  def may?(conn, "threads/open_close", _, _), do: signed_in?(conn)

  def may?(_conn, path, action, _) do
    Logger.debug(fn -> "--- CAUTION: no ability defined for path #{path} and action #{action}" end)
    false
  end

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
end
