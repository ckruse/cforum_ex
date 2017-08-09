# -*- coding: utf-8 -*-

defmodule CforumWeb.Plug.CurrentUser do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads and assigns the
  current user
  """
  def init(opts), do: opts

  def call(conn, _opts) do
    uid = Plug.Conn.get_session(conn, :user_id)

    current_user = if uid != nil, do: Cforum.Accounts.Users.get_user(uid), else: nil
    Plug.Conn.assign(conn, :current_user, current_user)
  end
end

# eof
