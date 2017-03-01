defmodule Guardian.Plug.VerifyRememberMe do
  @moduledoc """
  Use this plug to load a remember me cookie and convert it into an access token

  ## Example

      plug Guardian.Plug.VerifyRememberMe

  You can also specify a location to look for the token

  ## Example

      plug Guardian.Plug.VerifyRememberMe, key: :secret

  This should be run after Guardian.Plug.VerifySession

  It assumes that there is a cookie called 'remember_me' and that it has a
  refresh type token
  """
  import Guardian.Keys

  @doc false
  def init(opts \\ %{}), do: Enum.into(opts, %{})

  @doc false
  def call(conn, opts) do
    key = Map.get(opts, :key, :default)

    if Guardian.Plug.authenticated?(conn, key) do
      # we're already authenticated somehow either from the session or header
      conn
    else
      # do we find a cookie
      jwt = conn.req_cookies["remember_me"]  # options could specify this
      case exchange!(jwt, "refresh", "access") do # options could specify these too 
        {:ok, access_jwt, new_claims} ->
          conn
          |> Guardian.Plug.set_claims({:ok, new_claims}, key)
          |> Guardian.Plug.set_current_token(access_jwt, key)
        _error -> conn
      end
    end
  end

  defp exchange!(nil, _, _), do: {:error, :not_found}

  # this function could go into guardian itself
  defp exchange!(jwt, from, to) do
    case Guardian.decode_and_verify(jwt, typ: from) do # only accept remember me tokens of typ "refresh"
      { :ok, claims } ->
        new_claims = claims
          |> Map.drop(["jti", "iat", "exp", "nbf"])
          |> Guardian.Claims.jti
          |> Guardian.Claims.nbf
          |> Guardian.Claims.iat
          |> Guardian.Claims.ttl

        {:ok, resource} = Guardian.serializer.from_token(new_claims["sub"])

        Guardian.encode_and_sign(resource, to, new_claims)
      error -> error
    end
  end
end
