defmodule CforumWeb.Plug.CurrentForum do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads and assigns the current
  forum; if the forum could not be found it throws an 404 error
  """

  alias Cforum.Forums

  def init(opts), do: opts

  def call(conn, _opts) do
    val = conn.params["curr_forum"]

    forum = case val do
             nil ->
                nil
              slug when slug == "all" ->
                nil
              slug ->
                Forums.get_forum_by_slug!(slug)
            end

    Plug.Conn.assign(conn, :current_forum, forum)
  end
end
