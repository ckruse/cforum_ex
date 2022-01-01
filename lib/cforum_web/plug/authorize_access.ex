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
    module = Phoenix.Controller.controller_module(conn)

    if Abilities.may?(conn, module, action) do
      conn
    else
      if Kernel.function_exported?(module, :not_allowed, 2),
        do: module.not_allowed(conn, action),
        else: raise(Cforum.Errors.ForbiddenError, conn: conn)
    end
  end
end
