defmodule CforumWeb.Plug.CurrentUser do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads and assigns the
  current user
  """

  alias Cforum.Users
  alias Cforum.Helpers

  def init(opts), do: opts

  def call(conn, _opts) do
    uid = Plug.Conn.get_session(conn, :user_id)
    current_user = if uid != nil, do: Cforum.Users.get_user(uid), else: nil

    conn
    |> Plug.Conn.assign(:current_user, current_user)
    |> Plug.Conn.assign(:is_moderator, Users.moderator?(current_user))
    |> put_user_token(current_user)
  end

  @registration_paths ["/registrations/new", "/registrations", "/registrations/confirm"]

  defp put_user_token(%{request_path: path} = conn, nil) when path in @registration_paths,
    do: conn

  defp put_user_token(conn, nil) do
    if valid_cookie?(conn),
      do: conn,
      else: Plug.Conn.put_resp_cookie(conn, "cf_sess", token(conn), max_age: 600)
  end

  defp put_user_token(conn, current_user) do
    token = Phoenix.Token.sign(conn, "user socket", current_user.user_id)
    Plug.Conn.assign(conn, :user_token, token)
  end

  defp token(conn),
    do: Phoenix.Token.sign(conn, "registering", Timex.to_unix(Timex.now()))

  defp valid_cookie?(conn) do
    Helpers.present?(conn.cookies["cf_sess"]) &&
      Phoenix.Token.verify(conn, "registering", conn.cookies["cf_sess"], max_age: 600)
  end
end
