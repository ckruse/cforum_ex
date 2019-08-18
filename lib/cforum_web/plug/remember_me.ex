# -*- coding: utf-8 -*-

defmodule CforumWeb.Plug.RememberMe do
  @moduledoc """
  This plug is plugged in the browser pipeline and implements a „remember me”
  behaviour:

  - if the user is signed in it does nothing
  - if the user isn't signed in it checks if there is a `remember_me` cookie
  - if there is a `remember_me` cookie it loads the user object, signs in the
    user (sets `user_id` in session) and assigns the current_user
  """

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      # do we find a cookie
      token = conn.req_cookies["remember_me"]

      with {:ok, uid} <- Phoenix.Token.verify(CforumWeb.Endpoint, "user", token, max_age: 2_592_000),
           current_user when not is_nil(current_user) <- Cforum.Accounts.Users.get_user(uid) do
        conn
        |> Plug.Conn.put_session(:user_id, current_user.user_id)
        |> Plug.Conn.configure_session(renew: true)
        |> Plug.Conn.assign(:current_user, current_user)
      else
        _ -> conn
      end
    end
  end
end

# eof
