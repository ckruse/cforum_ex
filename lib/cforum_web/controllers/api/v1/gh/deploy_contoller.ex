defmodule CforumWeb.Api.Gh.DeployController do
  use CforumWeb, :controller

  def deploy(conn, _params) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
    |> Plug.Conn.send_resp(403, "{\"status\":\"ok\"}")
  end

  def allowed?(_conn, _, _), do: true
end
