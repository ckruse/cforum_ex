defmodule CforumWeb.Plug.SetViewAll do
  @moduledoc """
  This plug is plugged in the browser pipeline and sets the view_all switch if
  the user may use it and if it is present in the query parameters
  """

  alias Cforum.Accounts.User

  def init(opts), do: opts

  def call(conn, _) do
    if conn.params["view_all"] && may_view_all?(conn.assigns[:current_user], conn.assigns[:current_forum]),
      do: Plug.Conn.assign(conn, :view_all, true),
      else: Plug.Conn.assign(conn, :view_all, false)
  end

  defp may_view_all?(%User{admin: true}, _), do: true
  defp may_view_all?(user, forum), do: Cforum.Abilities.Helpers.access_forum?(user, forum, :moderate)
end
