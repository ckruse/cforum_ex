# -*- coding: utf-8 -*-

defmodule CforumWeb.Plug.RememberMe do
  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      # do we find a cookie
      token = conn.req_cookies["remember_me"]
      case Phoenix.Token.verify(CforumWeb.Endpoint, "user", token, max_age: 2_592_000) do
        {:ok, uid} ->
          current_user = Cforum.Accounts.Users.get_user(uid)
          conn
          |> Plug.Conn.put_session(:user_id, current_user.user_id)
          |> Plug.Conn.configure_session(renew: true)
          |> Plug.Conn.assign(:current_user, current_user)

        {:error, _} ->
          conn
      end
    end
  end
end

# eof
