defmodule CforumWeb.Plug.UpdateLastVisit do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads and assigns the
  current user
  """

  alias Cforum.Users
  alias Cforum.Users.User

  def init(opts), do: opts

  def call(conn, _opts) do
    if update_last_visit?(conn.assigns[:current_user]),
      do: Cforum.Helpers.AsyncHelper.run_async(fn -> Users.update_last_visit(conn.assigns[:current_user]) end)

    conn
  end

  defp update_last_visit?(nil), do: false
  defp update_last_visit?(%User{last_visit: nil}), do: true
  defp update_last_visit?(%User{last_visit: lv}), do: Timex.after?(Timex.now(), Timex.shift(lv, minutes: 10))
end
