defmodule CforumWeb.Plug.RequireAdmin do
  alias Cforum.Helpers

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    if Helpers.blank?(user) || !user.admin,
      do: raise(Cforum.Errors.ForbiddenError, conn: conn),
      else: conn
  end
end
