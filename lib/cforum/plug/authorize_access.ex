defmodule Cforum.Plug.AuthorizeAccess do
  import Cforum.Router.Helpers
  import Cforum.Gettext
  alias Cforum.Abilities

  def init(opts), do: opts

  def call(conn, opts) do
    path = Phoenix.Controller.controller_module(conn)
    |> Atom.to_string
    |> String.replace(~r{^Elixir\.Cforum\.}, "")
    |> String.replace(~r{Controller$}, "")
    |> Macro.underscore

    action = Phoenix.Controller.action_name(conn)

    if action_valid?(conn, path, action, opts) do
      conn
    else
      if Mix.env == :dev, do: raise "Authorization required"
      conn
      |> Phoenix.Controller.put_flash(:error, gettext("You don't have access to this page!"))
      |> Phoenix.Controller.redirect(to: session_path(conn, :new))
      |> Plug.Conn.halt
    end
  end

  defp action_valid?(conn, path, action, opts) do
    cond do
      is_list(opts[:only]) && !(action in opts[:only]) ->
        true
      is_list(opts[:only]) && (action in opts[:only]) ->
        Abilities.may?(conn, path, action)
      true ->
        Abilities.may?(conn, path, action)
    end
  end
end
