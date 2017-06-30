defmodule Cforum.Plug.CurrentForum do
  alias Cforum.Repo
  alias Cforum.Forums.Forum

  def init(opts), do: opts

  def call(conn, _opts) do
    val = conn.params["curr_forum"]

    forum = case val do
             nil ->
                nil
              slug when slug == "all" ->
                nil
              slug ->
                Repo.get_by!(Forum, slug: slug)
            end

    Plug.Conn.assign(conn, :current_forum, forum)
  end
end
