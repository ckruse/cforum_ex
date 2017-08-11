defmodule CforumWeb.Plug.LoadSettings do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads these settings objects:

  - global settings
  - forum settings
  - user settings
  """

  alias Cforum.Accounts.Setting
  alias Cforum.Accounts.Settings

  #
  # TODO use context to load settings; define API
  #

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]
    forum = conn.assigns[:current_forum]

    settings = Settings.load_relevant_settings(forum, user)
    set_confs(conn, settings)
  end

  defp set_confs(conn, []), do: conn
  defp set_confs(conn, [conf = %Setting{user_id: nil, forum_id: nil} | tail]) do
    Plug.Conn.assign(conn, :global_config, conf)
    |> set_confs(tail)
  end
  defp set_confs(conn, [conf = %Setting{forum_id: nil} | tail]) do
    Plug.Conn.assign(conn, :user_config, conf)
    |> set_confs(tail)
  end
  defp set_confs(conn, [conf = %Setting{user_id: nil} | tail]) do
    Plug.Conn.assign(conn, :forum_config, conf)
    |> set_confs(tail)
  end
  defp set_confs(a, b), do: raise "a forum specific user config? wtf?\n\n#{inspect a}\n\n#{inspect b}"
end
