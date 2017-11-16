defmodule CforumWeb.Plug.EnsureAdmin do
  @moduledoc """
  This plug is plugged in pipelines, where only admins have access (e.g. the
  admin interface). It ensures that there is a current user and that he is an
  administrator and shows a 403 error page if user is not an admin.
  """

  def init(opts), do: opts

  def call(conn, _) do
    if conn.assigns[:current_user] == nil || !conn.assigns[:current_user].admin do
      conn
      |> Plug.Conn.halt()
      |> CforumWeb.ErrorHandler.admin_required(conn.params)
    else
      conn
    end
  end
end
