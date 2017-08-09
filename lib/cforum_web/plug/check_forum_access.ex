defmodule CforumWeb.Plug.CheckForumAccess do
  @moduledoc """
  This plug is plugged in the browser pipeline; it checks if the user of the
  current request has access to a forum (if he tries to access one); if not
  the user gets a 403 error message
  """

  alias Cforum.Forums.Forum
  alias Cforum.Accounts.User

  def init(opts), do: opts

  def call(conn, _opts) do
    if check_access(conn.assigns[:current_forum], conn.assigns[:current_user], conn.assigns[:visible_forums] || []) do
      conn
    else
      conn
      |> Plug.Conn.halt
      |> CforumWeb.ErrorHandler.access_forbidden(conn.params)
    end
  end

  defp check_access(forum, _user, _visible_forums) when forum == nil, do: true
  defp check_access(_forum, %User{admin: true}, _visible_forums), do: true
  defp check_access(forum, user, _visible_forums) when user == nil do
    forum.standard_permission == Forum.read || forum.standard_permission == Forum.write
  end

  defp check_access(forum, _user, visible_forums) do
    if Enum.member?([Forum.read, Forum.write, Forum.known_read, Forum.known_write], forum.standard_permission) do
      true
    else
      Enum.member?(visible_forums, forum)
    end
  end
end
