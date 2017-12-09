defmodule Cforum.Abilities do
  require Logger

  def may?(conn, path, action \\ :index, args \\ nil)

  def may?(conn, "users/user", :update, resource) do
    cuser = conn.assigns[:current_user]
    uid = if resource != nil, do: resource.user_id, else: String.to_integer(conn.params["user_id"] || conn.params["id"])
    cuser != nil && (cuser.admin || uid == cuser.user_id)
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

  def may?(_conn, path, action, _) do
    Logger.debug(fn -> "--- CAUTION: no ability defined for path #{path} and action #{action}" end)
    false
  end
end
