defmodule CforumWeb.Plug.EnsureAdmin do
  def init(opts), do: opts

  def call(conn, _) do
    if conn.assigns[:current_user] == nil || !conn.assigns[:current_user].admin do
      conn
      |> Plug.Conn.halt
      |> CforumWeb.ErrorHandler.admin_required(conn.params)
    else
      conn
    end
  end
end
