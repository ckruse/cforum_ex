defmodule Cforum.Threads.InvisibleThreads do
  import Ecto.Query, warn: false

  alias Cforum.Repo

  alias Cforum.Threads.Thread
  alias Cforum.Threads.InvisibleThread
  alias Cforum.Threads.ThreadHelpers

  alias Cforum.Messages.Message

  def list_invisible_threads(user, visible_forums, opts \\ []) do
    opts = Keyword.merge([page: 0, limit: 50, order: "newest-first", view_all: false], opts)

    q =
      from(thread in Thread,
        where:
          fragment(
            "EXISTS(SELECT thread_id FROM invisible_threads WHERE user_id = ? AND invisible_threads.thread_id = ?)",
            ^user.user_id,
            thread.thread_id
          ),
        order_by: ^ThreadHelpers.valid_ordering(opts[:order]),
        limit: ^opts[:limit],
        offset: ^(opts[:page] * opts[:limit])
      )
      |> ThreadHelpers.set_forum_id(visible_forums, nil)
      |> ThreadHelpers.set_view_all(opts[:view_all])

    cnt =
      q
      |> exclude(:select)
      |> exclude(:order_by)
      |> select(count("*"))
      |> Repo.one!()

    threads =
      q
      |> Repo.all()
      |> Repo.preload(Thread.default_preloads())
      |> Repo.preload(
        messages:
          {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at])
           |> ThreadHelpers.set_view_all(opts[:view_all]), Message.default_preloads()}
      )

    {cnt, threads}
  end

  def hide_thread(user, thread) do
    %InvisibleThread{}
    |> InvisibleThread.changeset(%{thread_id: thread.thread_id, user_id: user.user_id})
    |> Repo.insert()
  end

  def unhide_thread(user, thread) do
    invisible =
      InvisibleThread
      |> Repo.get_by(user_id: user.user_id, thread_id: thread.thread_id)

    if invisible, do: Repo.delete(invisible), else: nil
  end
end
