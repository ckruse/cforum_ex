defmodule CforumWeb.Plug.LoadSettings do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads these settings objects:

  - global settings as `@global_config`/`:global_config`
  - forum settings as `@forum_config`/`:forum_config`
  - user settings as `@user_config`/`:user_config`
  """

  alias Cforum.Accounts.Setting
  alias Cforum.Accounts.Settings

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]
    forum = conn.assigns[:current_forum]

    settings = Settings.load_relevant_settings(forum, user)
    set_confs(conn, settings)
  end

  defp set_confs(conn, confs) do
    Enum.reduce(confs, conn, fn
      conf = %Setting{user_id: nil, forum_id: nil}, conn -> Plug.Conn.assign(conn, :global_config, conf)
      conf = %Setting{forum_id: nil}, conn -> Plug.Conn.assign(conn, :user_config, conf)
      conf = %Setting{user_id: nil}, conn -> Plug.Conn.assign(conn, :forum_config, conf)
    end)
  end
end
