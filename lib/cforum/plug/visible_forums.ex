defmodule Cforum.Plug.VisibleForums do
  alias Cforum.Repo
  alias Cforum.Forums.Forum

  def init(opts), do: opts

  def call(conn, _) do
    forums = Forum |>
      Forum.visible_forums(conn.assigns[:current_user]) |>
      Forum.ordered |>
      Repo.all

    Plug.Conn.assign(conn, :visible_forums, forums)
  end
end
