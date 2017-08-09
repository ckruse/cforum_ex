defmodule CforumWeb.Plug.VisibleForums do
  alias Cforum.Forums

  def init(opts), do: opts

  def call(conn, _) do
    forums = Forums.list_visible_forums(conn.assigns[:current_user])
    Plug.Conn.assign(conn, :visible_forums, forums)
  end
end
