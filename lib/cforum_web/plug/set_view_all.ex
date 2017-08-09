defmodule CforumWeb.Plug.SetViewAll do
  @moduledoc """
  This plug is plugged in the browser pipeline and sets the view_all switch if
  the user may use it and if it is present in the query parameters
  """

  def init(opts), do: opts

  # TODO set view_all to true/false based on authorization and URL flag
  def call(conn, _) do
    Plug.Conn.assign(conn, :view_all, false)
  end
end
