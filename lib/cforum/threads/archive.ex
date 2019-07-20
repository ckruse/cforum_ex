defmodule Cforum.Threads.Archive do
  import Ecto.Query, warn: false

  alias Cforum.Repo

  alias Cforum.Threads.Thread
  alias Cforum.Threads.ThreadHelpers

  alias Cforum.Messages.Message

  def list_archived_threads(forum, visible_forums, from, to, opts \\ []) do
    opts = Keyword.merge([view_all: false, limit: 50, page: 0, order: "newest-first"], opts)

    from(thread in Thread,
      where: thread.created_at >= ^from and thread.created_at <= ^to,
      order_by: ^ThreadHelpers.valid_ordering(opts[:order]),
      limit: ^opts[:limit],
      offset: ^(opts[:page] * opts[:limit])
    )
    |> ThreadHelpers.set_forum_id(visible_forums, forum)
    |> ThreadHelpers.set_view_all(opts[:view_all])
    |> Repo.all()
    |> Repo.preload(Thread.default_preloads())
    |> Repo.preload(
      messages:
        {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at])
         |> ThreadHelpers.set_view_all(opts[:view_all]), Message.default_preloads()}
    )
  end

  def list_archive_years(forum, visible_forums, opts \\ []) do
    opts = Keyword.merge([view_all: false], opts)

    from(
      thread in Thread,
      select: fragment("DATE_TRUNC('month', created_at)"),
      where: thread.deleted == false,
      group_by: fragment("1"),
      order_by: fragment("1 DESC")
    )
    |> ThreadHelpers.set_forum_id(visible_forums, forum)
    |> ThreadHelpers.set_view_all(opts[:view_all])
    |> Repo.all()
    |> Enum.reduce(%{}, fn month, archive -> Map.update(archive, month.year, [month], &[month | &1]) end)
    |> Map.values()
  end

  def list_archive_months(forum, visible_forums, year, opts \\ []) do
    opts = Keyword.merge([view_all: false], opts)

    from(
      thread in Thread,
      select: fragment("DATE_TRUNC('month', created_at) AS year"),
      where: thread.deleted == false and fragment("EXTRACT('year' from ?)", thread.created_at) == type(^year, :integer),
      group_by: fragment("1"),
      order_by: fragment("1 DESC")
    )
    |> ThreadHelpers.set_forum_id(visible_forums, forum)
    |> ThreadHelpers.set_view_all(opts[:view_all])
    |> Repo.all()
  end
end
