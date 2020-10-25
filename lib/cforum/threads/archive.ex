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

  def count_archived_threads(forum, visible_forums, from, to, opts \\ []) do
    opts = Keyword.merge([view_all: false], opts)

    from(thread in Thread, where: thread.created_at >= ^from and thread.created_at <= ^to, select: count())
    |> ThreadHelpers.set_forum_id(visible_forums, forum)
    |> ThreadHelpers.set_view_all(opts[:view_all])
    |> Repo.one()
  end

  def list_archive_years(forum, visible_forums, opts \\ []) do
    opts = Keyword.merge([view_all: false], opts)

    from(
      thread in Thread,
      select: fragment("DATE_TRUNC('month', created_at)"),
      group_by: fragment("1"),
      order_by: fragment("1 DESC")
    )
    |> ThreadHelpers.set_forum_id(visible_forums, forum)
    |> maybe_filter_deleted(opts[:view_all])
    |> Repo.all()
    |> Enum.reduce(%{}, fn month, archive -> Map.update(archive, month.year, [month], &[month | &1]) end)
    |> Map.values()
  end

  defp maybe_filter_deleted(q, true), do: q

  defp maybe_filter_deleted(q, _) do
    from(thread in q,
      where: thread.deleted == false,
      where:
        fragment(
          "EXISTS(SELECT message_id FROM messages WHERE messages.deleted = false AND messages.thread_id = ?)",
          thread.thread_id
        )
    )
  end

  def list_archive_months(forum, visible_forums, year, opts \\ []) do
    opts = Keyword.merge([view_all: false], opts)

    from(
      thread in Thread,
      select: fragment("DATE_TRUNC('month', created_at) AS year"),
      where: fragment("EXTRACT('year' from ?)", thread.created_at) == type(^year, :integer),
      group_by: fragment("1"),
      order_by: fragment("1 DESC")
    )
    |> maybe_filter_deleted(opts[:view_all])
    |> ThreadHelpers.set_forum_id(visible_forums, forum)
    |> ThreadHelpers.set_view_all(opts[:view_all])
    |> Repo.all()
  end
end
