defmodule CforumWeb.Plug.SetViewAll do
  @moduledoc """
  This plug is plugged in the browser pipeline and sets the view_all switch if
  the user may use it and if it is present in the query parameters
  """

  alias Cforum.Abilities

  def init(opts), do: opts

  def call(conn, _) do
    if conn.params["view_all"] && Abilities.access_forum?(conn, :moderate),
      do: Plug.Conn.assign(conn, :view_all, true),
      else: Plug.Conn.assign(conn, :view_all, false)
  end
end
