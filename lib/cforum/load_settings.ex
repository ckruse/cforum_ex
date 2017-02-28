defmodule Cforum.Plug.LoadSettings do
  alias Cforum.Setting
  alias Cforum.Repo

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]
    forum = conn.assigns[:current_forum]

    conn
    |> load_user_conf(user)
    |> load_forum_conf(forum)
    |> load_global_conf
  end

  def load_user_conf(conn, user) when user == nil, do: conn
  def load_user_conf(conn, user) do
    conf = Repo.get_by(Setting, user_id: user.user_id)
    Plug.Conn.assign(conn, :user_config, conf)
  end

  def load_forum_conf(conn, forum) when forum == nil, do: conn
  def load_forum_conf(conn, forum) do
    conf = Repo.get_by(Setting, forum_id: forum.forum_id)
    Plug.Conn.assign(conn, :forum_config, conf)
  end

  def load_global_conf(conn) do
    conf = Setting |> Setting.global() |> Repo.one()
    Plug.Conn.assign(conn, :global_config, conf)
  end
end
