defmodule CforumWeb.Plug.UpdateLastVisit do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads and assigns the
  current user
  """

  alias Cforum.Accounts.Users

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user],
      do: Cforum.Helpers.AsyncHelper.run_async(fn -> Users.update_last_visit(conn.assigns[:current_user]) end)

    conn
  end
end
