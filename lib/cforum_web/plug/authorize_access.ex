defmodule CforumWeb.Plug.AuthorizeAccess do
  @moduledoc """
  This plug is pluggable in controllers for authorizing actions based on our
  Abilities module. It constructs a path by the controller name and then calls
  `Abilities.may?(mod, action)`

  ## Examples

      # Authorize access to all actions
      plug AuthorizeAccess

      # Authorize acess only for some actions:
      plug AuthorizeAccess, only: [:new, :create]
  """
  alias Cforum.Abilities

  def init(opts), do: opts

  def call(conn, _opts) do
    action = Phoenix.Controller.action_name(conn)

    if Abilities.may?(conn, Phoenix.Controller.controller_module(conn), action),
      do: conn,
      else: raise(Cforum.Errors.ForbiddenError, conn: conn)
  end
end
