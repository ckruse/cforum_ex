defmodule CforumWeb.Api.Gh.DeployController do
  use CforumWeb, :controller

  alias Cforum.Helpers

  def deploy(conn, %{"action" => "created", "release" => %{"html_url" => url}}) do
    version = Regex.replace(~r{.*/}, url, "")
    script = Application.get_env(:cforum, :deploy_script)

    if Helpers.present?(script),
      do: Task.start(fn -> System.cmd(script, [version]) end)

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
    |> Plug.Conn.send_resp(200, "{\"status\":\"ok\"}")
  end

  def deploy(conn, _) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
    |> Plug.Conn.send_resp(403, "{\"status\":\"unknown\"}")
  end

  def allowed?(_conn, _, _), do: true
end
