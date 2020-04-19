defmodule CforumWeb.Plug.LoadSettings do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads these settings objects:

  - global settings as `@global_config`/`:global_config`
  - forum settings as `@forum_config`/`:forum_config`
  - user settings as `@user_config`/`:user_config`
  """

  alias Cforum.ConfigManager

  def init(opts), do: opts

  def call(conn, _opts) do
    settings = ConfigManager.settings_map(conn.assigns[:current_forum], conn.assigns[:current_user])

    conn
    |> Plug.Conn.assign(:global_config, settings[:global])
    |> Plug.Conn.assign(:user_config, settings[:user])
    |> Plug.Conn.assign(:forum_config, settings[:forum])
  end
end
