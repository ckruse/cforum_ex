defmodule Cforum.Plug.LoadSettings do
  alias Cforum.Accounts.Setting
  alias Cforum.Repo

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]
    forum = conn.assigns[:current_forum]

    settings = Setting |> Setting.load_all(forum, user) |> Repo.all
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
