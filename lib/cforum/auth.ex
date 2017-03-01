defmodule Cforum.Auth do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Cforum.User

  def login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user, :access)
  end

  def authenticate(conn, login, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = User |> User.by_username_or_email(login) |> repo.one

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
