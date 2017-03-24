defmodule Cforum.Abilities do
  require Logger

  def may?(conn, path, action \\ :index, args \\ nil)
  def may?(conn, "users/user", :show_votes, resource) do
    cuser = conn.assigns[:current_user]
    uid = if resource != nil, do: resource.user_id, else: String.to_integer(conn.params["id"])
    cuser != nil && uid == cuser.user_id
  end

  def may?(_conn, path, action, _) do
    Logger.debug "--- CAUTION: no ability defined for path #{path} and action #{action}"
    false
  end
end
