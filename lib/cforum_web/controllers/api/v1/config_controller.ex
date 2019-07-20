defmodule CforumWeb.Api.V1.ConfigController do
  use CforumWeb, :controller

  alias Cforum.ConfigManager

  def show(conn, _params) do
    config =
      Enum.reduce(ConfigManager.user_config_keys(), %{}, fn key, opts ->
        Map.put(opts, key, ConfigManager.uconf(conn, key))
      end)

    json(conn, config)
  end

  def allowed?(_conn, _, _), do: true
end
