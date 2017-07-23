defmodule Cforum.Plug.EnsureLoggedIn do
  def init(opts), do: opts

  def call(conn, opts) do
    action = Phoenix.Controller.action_name(conn)

    if action_valid?(action, opts) do
      if conn.assigns[:current_user] == nil do
        conn
        |> Plug.Conn.halt
        |> Cforum.GuardianErrorHandler.unauthenticated(conn.params)
      else
        conn
      end
    else
      conn
    end
  end

  defp action_valid?(action, opts) do
    cond do
      is_list(opts[:only]) && !(action in opts[:only]) ->
        false
      is_list(opts[:only]) && (action in opts[:only]) ->
        true
      opts[:only] == nil ->
        true
      true ->
        false
    end
  end
end
