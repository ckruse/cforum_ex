defmodule CforumWeb.Plug.SetViewAll do
  @moduledoc """
  This plug is plugged in the browser pipeline and sets the view_all switch if
  the user may use it and if it is present in the query parameters
  """

  alias Cforum.Abilities
  alias CforumWeb.Views.Helpers.Path

  def init(opts), do: opts

  def call(conn, _) do
    if conn.params["view_all"] && Abilities.access_forum?(conn, :moderate) do
      conn
      |> Plug.Conn.assign(:view_all, true)
      |> Path.add_url_flag(:view_all, "yes")
    else
      conn
      |> Plug.Conn.assign(:view_all, false)
      |> Path.del_url_flag(:view_all)
    end
  end
end
