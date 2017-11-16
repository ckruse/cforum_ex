defmodule CforumWeb.Plug.EnsureAnonymous do
  @moduledoc """
  This plug can be plugged in controllers and ensures that a user is not
  signed in. It can be limited to actions by the `only` keyword. It shows
  a 403 error page when user is signed in.

  ## Examples

      # ensure that user isn't signed in for all actions
      plug EnsureAnonymous

      # ensure that user isn't signed in only for some actions
      plug EnsureAnonymous, only: [:sign_in]
  """

  def init(opts), do: opts

  def call(conn, opts) do
    action = Phoenix.Controller.action_name(conn)

    if action_valid?(action, opts) do
      if conn.assigns[:current_user] == nil do
        conn
      else
        conn
        |> CforumWeb.ErrorHandler.anonymous_required(conn.params)
      end
    else
      conn
    end
  end

  defp action_valid?(action, opts) do
    cond do
      is_list(opts[:only]) && !(action in opts[:only]) ->
        false

      is_list(opts[:only]) && action in opts[:only] ->
        true

      opts[:only] == nil ->
        true

      true ->
        false
    end
  end
end
