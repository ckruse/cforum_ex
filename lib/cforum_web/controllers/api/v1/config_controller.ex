defmodule CforumWeb.Api.V1.ConfigController do
  use CforumWeb, :controller

  def show(conn, _params) do
    config =
      Enum.reduce(Cforum.ConfigManager.user_config_keys(), %{}, fn key, opts ->
        Map.put(opts, key, uconf(conn, key))
      end)

    json(conn, config)
  end

  def allowed?(_conn, _, _), do: true
end
