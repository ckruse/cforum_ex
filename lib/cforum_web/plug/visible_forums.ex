defmodule CforumWeb.Plug.VisibleForums do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads and assigns the forums
  visible to the current user.
  """

  alias Cforum.Forums

  def init(opts), do: opts

  def call(conn, _) do
    forums = Forums.list_visible_forums(conn.assigns[:current_user])
    Plug.Conn.assign(conn, :visible_forums, forums)
  end
end
