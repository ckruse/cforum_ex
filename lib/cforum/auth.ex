defmodule Cforum.Auth do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Cforum.Accounts.Users

  def login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user, :access)
  end

  def authenticate(conn, login, given_pass, _opts) do
    user = Users.get_user_by_username_or_email!(login)

    cond do
      user && checkpw(given_pass, user.encrypted_password) ->
        {:ok, login(conn, user)}

      user ->
        {:error, :unauthorized, conn}

      true ->
        # just waste some time for timing sidechannel attacks
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end
end
