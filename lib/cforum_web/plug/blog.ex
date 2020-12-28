defmodule CforumWeb.Plug.Blog do
  @behaviour Plug

  alias Cforum.Forums

  def init(opts), do: opts

  def call(conn, _),
    do: Plug.Conn.assign(conn, :current_forum, Forums.get_forum_by_type("blog"))
end
