defmodule Cforum.DeployTask do
  alias Cforum.Helpers

  def deploy(conn, payload) when is_binary(payload),
    do: deploy(conn, Jason.decode!(payload))

  def deploy(_conn, %{"action" => "created", "release" => %{"html_url" => url}}) do
    version = Regex.replace(~r{.*/}, url, "")
    script = Application.get_env(:cforum, :deploy_script)

    if Helpers.present?(script),
      do: Task.start(fn -> System.cmd(script, [version]) end)
  end

  def deploy(_conn, _),
    do: nil
end
