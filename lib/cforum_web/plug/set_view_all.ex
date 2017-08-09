defmodule CforumWeb.Plug.SetViewAll do
  def init(opts), do: opts

  # TODO set view_all to true/false based on authorization and URL flag
  def call(conn, _) do
    Plug.Conn.assign(conn, :view_all, false)
  end
end
