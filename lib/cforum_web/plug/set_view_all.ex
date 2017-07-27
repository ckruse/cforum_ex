defmodule CforumWeb.Plug.SetViewAll do
  def init(opts), do: opts

  # TODO
  def call(conn, _) do
    Plug.Conn.assign(conn, :view_all, false)
  end
end
