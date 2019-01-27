defmodule Cforum.Forums.Threads do
  @moduledoc """
  The boundary for the Threads system.
  """

  import Ecto.{Query, Changeset}, warn: false

  alias Cforum.Repo

  alias Cforum.Forums.{Thread, InvisibleThread, OpenCloseState, Message}
  alias Cforum.Forums.Messages
  alias Cforum.System
  alias Cforum.Caching

  @doc """
  Returns the list of unarchived threads.

  ## Examples

      iex> list_threads()
      [%Thread{}, ...]

  """
  def list_threads(forum, visible_forums)
  def list_threads(forum, _) when not is_nil(forum), do: list_threads(nil, [forum])

  def list_threads(_, forums) do
    threads =
      Caching.fetch(:cforum, :threads, fn ->
        from(thread in Thread, where: thread.archived == false, order_by: [desc: :created_at])
        |> Repo.all()
        |> Repo.preload(Thread.default_preloads())
        |> Repo.preload(
          messages:
            {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at]),
             Message.default_preloads()}
        )
      end)

    if forums == nil || forums == [] do
      threads
    else
      forum_ids = Enum.map(forums, & &1.forum_id)
      Enum.filter(threads, &(&1.forum_id in forum_ids))
    end
  end

  @doc """
  Rejects deleted message based on a boolean parameter
  """

  def reject_deleted_threads(threads, view_all \\ false)
  def reject_deleted_threads(threads, true), do: threads

  def reject_deleted_threads(nil, _), do: nil

  def reject_deleted_threads(%Thread{} = thread, view_all) do
    reject_deleted_threads([thread], view_all)
    |> List.first()
  end

  def reject_deleted_threads(threads, _) do
    Enum.reduce(threads, [], fn thread, list ->
      thread = Map.put(thread, :messages, Enum.filter(thread.messages, &(&1.deleted == false)))
      [thread | list]
    end)
    |> Enum.reject(&(&1.messages == []))
    |> Enum.reverse()
  end

  @doc """
  Sort the threads ascending, descending or by the newest message
  """

  def sort_threads(threads, direction, opts \\ [])

  def sort_threads(threads, "ascending", opts) do
    Enum.sort(threads, fn a, b ->
      cond do
        a.sticky == b.sticky && !opts[:ignore_sticky] -> Timex.compare(a.created_at, b.created_at) <= 0
        a.sticky && !opts[:ignore_sticky] -> true
        b.sticky && !opts[:ignore_sticky] -> false
        true -> Timex.compare(a.created_at, b.created_at) <= 0
      end
    end)
  end

  def sort_threads(threads, "descending", opts) do
    Enum.sort(threads, fn a, b ->
      cond do
        a.sticky == b.sticky && !opts[:ignore_sticky] -> Timex.compare(a.created_at, b.created_at) >= 0
        a.sticky && !opts[:ignore_sticky] -> true
        b.sticky && !opts[:ignore_sticky] -> false
        true -> Timex.compare(a.created_at, b.created_at) >= 0
      end
    end)
  end

  def sort_threads(threads, "newest-first", opts) do
    Enum.sort(threads, fn a, b ->
      cond do
        a.sticky == b.sticky && !opts[:ignore_sticky] -> Timex.compare(a.latest_message, b.latest_message) >= 0
        a.sticky && !opts[:ignore_sticky] -> true
        b.sticky && !opts[:ignore_sticky] -> false
        true -> Timex.compare(a.latest_message, b.latest_message) >= 0
      end
    end)
  end

  def apply_user_infos(threads, user, opts \\ [])

  def apply_user_infos(%Thread{} = thread, user, opts),
    do: Cforum.Forums.Messages.IndexHelper.set_user_attributes([thread], user, opts) |> List.first()

  def apply_user_infos(threads, user, opts),
    do: Cforum.Forums.Messages.IndexHelper.set_user_attributes(threads, user, opts)

  def build_message_trees(threads, message_order), do: Enum.map(threads, &build_message_tree(&1, message_order))

  def build_message_tree(thread, ordering) do
    sorted_messages = Messages.sort_messages(thread.messages, ordering)

    tree =
      sorted_messages
      |> Enum.reverse()
      |> Enum.reduce(%{}, fn msg, map ->
        msg = %Message{msg | messages: Map.get(map, msg.message_id, [])}
        Map.update(map, msg.parent_id, [msg], fn msgs -> [msg | msgs] end)
      end)
      |> Map.get(nil)
      |> hd

    thread
    |> Map.put(:sorted_messages, sorted_messages)
    |> Map.put(:message, tree)
    |> Map.put(:tree, tree)
    |> Map.put(:accepted, Enum.filter(sorted_messages, &(&1.flags["accepted"] == "yes")))
  end

  def paged_thread_list(threads, use_paging, page, limit)

  def paged_thread_list(threads, true, page, limit) do
    {sticky, normal} =
      Enum.reduce(threads, {[], []}, fn
        %Thread{sticky: true} = thread, {sticky, normal} -> {[thread | sticky], normal}
        thread, {sticky, normal} -> {sticky, [thread | normal]}
      end)

    limit = limit - length(sticky)

    Enum.concat(Enum.reverse(sticky), normal |> Enum.reverse() |> Enum.slice(page * limit, limit))
  end

  def paged_thread_list(threads, false, _, _), do: threads

  def reject_invisible_threads(threads, user, view_all \\ false)
  def reject_invisible_threads(threads, _, true), do: threads
  def reject_invisible_threads(threads, nil, _), do: threads

  def reject_invisible_threads(threads, user, _) do
    tids = Enum.map(threads, & &1.thread_id)

    invisible =
      from(iv in InvisibleThread, select: iv.thread_id, where: iv.user_id == ^user.user_id and iv.thread_id in ^tids)
      |> Repo.all()

    Enum.reject(threads, &Enum.member?(invisible, &1.thread_id))
  end

  def reject_read_threads(threads, reject)

  def reject_read_threads(threads, false),
    do: threads

  def reject_read_threads(threads, _),
    do: Enum.filter(threads, fn thread -> Enum.any?(thread.messages, &(not &1.attribs[:is_read])) end)

  def filter_wo_answer(threads, filter \\ true)
  def filter_wo_answer(threads, false), do: threads

  def filter_wo_answer(threads, _),
    do: Enum.filter(threads, &(length(&1.messages) <= 1 && Messages.open?(List.first(&1.messages))))

  def ensure_found!(threads) when threads == [] or threads == nil, do: raise(Ecto.NoResultsError, queryable: Thread)
  def ensure_found!(threads), do: threads

  def list_archived_threads(forum, visible_forums, from, to, opts \\ []) do
    opts = Keyword.merge([view_all: false, limit: 50, page: 0, order: "newest-first"], opts)

    from(thread in Thread,
      where: thread.created_at >= ^from and thread.created_at <= ^to,
      order_by: ^valid_ordering(opts[:order]),
      limit: ^opts[:limit],
      offset: ^(opts[:page] * opts[:limit])
    )
    |> set_forum_id(visible_forums, forum)
    |> set_view_all(opts[:view_all])
    |> Repo.all()
    |> Repo.preload(Thread.default_preloads())
    |> Repo.preload(
      messages:
        {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at])
         |> set_view_all(opts[:view_all]), Message.default_preloads()}
    )
  end

  def list_archive_years(forum, visible_forums, opts \\ []) do
    opts = Keyword.merge([view_all: false], opts)

    from(
      thread in Thread,
      select: fragment("DATE_TRUNC('year', created_at) AS year"),
      where: thread.deleted == false,
      group_by: fragment("1"),
      order_by: fragment("1 DESC")
    )
    |> set_forum_id(visible_forums, forum)
    |> set_view_all(opts[:view_all])
    |> Repo.all()
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
    |> set_forum_id(visible_forums, forum)
    |> set_view_all(opts[:view_all])
    |> Repo.all()
  end

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
        order_by: ^valid_ordering(opts[:order]),
        limit: ^opts[:limit],
        offset: ^(opts[:page] * opts[:limit])
      )
      |> set_forum_id(visible_forums, nil)
      |> set_view_all(opts[:view_all])

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
           |> set_view_all(opts[:view_all]), Message.default_preloads()}
      )

    {cnt, threads}
  end

  defp set_view_all(q, false), do: from(m in q, where: m.deleted == false)
  defp set_view_all(q, true), do: q

  defp set_forum_id(q, visible_forums, nil) do
    visible_forums = Enum.map(visible_forums, & &1.forum_id)
    from(thread in q, where: thread.forum_id in ^visible_forums)
  end

  defp set_forum_id(q, _, forum), do: from(thread in q, where: thread.forum_id == ^forum.forum_id)

  defp valid_ordering("descending"), do: [desc: :created_at]
  defp valid_ordering("ascending"), do: [asc: :created_at]
  # falling back to "newest-first" for all other cases
  defp valid_ordering(_), do: [desc: :latest_message]

  @doc """
  Gets a single thread.

  Raises `Ecto.NoResultsError` if the Thread does not exist.

  ## Examples

      iex> get_thread!(123)
      %Thread{}

      iex> get_thread!(456)
      ** (Ecto.NoResultsError)

  """
  def get_thread!(id) do
    Thread
    |> Repo.get_by!(thread_id: id)
    |> Repo.preload(Thread.default_preloads())
    |> Repo.preload(
      messages:
        {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at]),
         Message.default_preloads()}
    )
  end

  def get_thread!(forum, visible_forums, id) do
    list_threads(forum, visible_forums)
    |> Enum.find(&(&1.thread_id == id))
    |> case do
      nil ->
        from(thread in Thread, where: thread.thread_id == ^id, order_by: [desc: :created_at])
        |> set_forum_id(visible_forums, forum)
        |> Repo.one()
        |> Repo.preload(Thread.default_preloads())
        |> Repo.preload(
          messages:
            {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at]),
             Message.default_preloads()}
        )

      thread ->
        thread
    end
    |> case do
      nil -> raise Ecto.NoResultsError, queryable: Thread
      thread -> thread
    end
  end

  @doc """
  Gets a single thread by its slug.

  Raises `Ecto.NoResultsError` if the Thread does not exist.

  ## Examples

      iex> get_thread!("2017/08/25/foo-bar")
      %Thread{}

      iex> get_thread!("2017/08/32/non-existant")
      ** (Ecto.NoResultsError)

  """
  def get_thread_by_slug!(forum, visible_forums, slug) do
    list_threads(forum, visible_forums)
    |> Enum.find(&(&1.slug == slug))
    |> case do
      nil ->
        from(thread in Thread, where: thread.slug == ^slug, order_by: [desc: :created_at])
        |> set_forum_id(visible_forums, forum)
        |> Repo.one()
        |> Repo.preload(Thread.default_preloads())
        |> Repo.preload(
          messages:
            {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at]),
             Message.default_preloads()}
        )

      thread ->
        thread
    end
    |> case do
      nil -> raise Ecto.NoResultsError, queryable: Thread
      thread -> thread
    end
  end

  @doc """
  Gets threads by their tid. Tids are historically not unique, so you might get more than one thread.

  Raises `Ecto.NoResultsError` if no thread could be found.

  ## Examples

      iex> get_threads_by_tid!(1)
      [%Thread{}]

      iex> get_thread!(-1)
      ** (Ecto.NoResultsError)

  """
  def get_threads_by_tid!(tid) do
    from(thread in Thread, where: thread.tid == ^tid, order_by: [desc: :created_at])
    |> Repo.all()
    |> Repo.preload(Thread.default_preloads())
    |> Repo.preload(
      messages:
        {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at]),
         Message.default_preloads()}
    )
    |> case do
      [] -> raise Ecto.NoResultsError, queryable: Thread
      threads -> threads
    end
  end

  def get_threads_by_message_ids(message_ids) do
    from(thread in Thread,
      where:
        thread.thread_id in fragment(
          "SELECT thread_id FROM messages WHERE message_id = ANY(?) AND deleted = false",
          ^message_ids
        ),
      order_by: [desc: :created_at]
    )
    |> Repo.all()
    |> Repo.preload(Thread.default_preloads())
    |> Repo.preload(
      messages:
        {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at]),
         Message.default_preloads()}
    )
  end

  def slug_taken?(slug) do
    from(t in Thread, where: t.slug == ^slug)
    |> Repo.exists?()
  end

  @doc """
  Creates a thread.

  ## Examples

      iex> create_thread(%{field: value})
      {:ok, %Thread{}}

      iex> create_thread(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_thread(attrs, user, forum, visible_forums, opts \\ [create_tags: false]) do
    retval =
      Repo.transaction(fn ->
        retval =
          %Thread{latest_message: DateTime.truncate(Timex.now(), :second)}
          |> Thread.changeset(attrs, forum, visible_forums)
          |> Repo.insert()

        case retval do
          {:ok, thread} ->
            create_message(attrs, user, visible_forums, thread, opts)

          {:error, t_changeset} ->
            thread = Ecto.Changeset.apply_changes(t_changeset)
            # we need a changeset with an action; since thread_id is empty this always fails
            create_message(attrs, user, visible_forums, thread)
        end
      end)

    with {:ok, {:ok, thread, message}} <- retval do
      {:ok, Repo.preload(thread, [:forum]), message}
    end
    |> maybe_notify_users()
    |> add_to_cache()
  end

  defp create_message(attrs, user, visible_forums, thread, opts \\ [create_tags: false]) do
    case Messages.create_message(attrs, user, visible_forums, thread, nil, opts) do
      {:ok, message} ->
        {:ok, thread, message}

      {:error, changeset} ->
        Repo.rollback(changeset)
    end
  end

  def maybe_notify_users({:ok, thread, message}) do
    Cforum.Forums.NotifyUsersMessageJob.notify_users_about_new_thread(thread, message)
    {:ok, thread, message}
  end

  def maybe_notify_users(val), do: val

  @doc """
  Updates a thread.

  ## Examples

      iex> update_thread(thread, %{field: new_value})
      {:ok, %Thread{}}

      iex> update_thread(thread, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_thread(%Thread{} = thread, attrs, forum, visible_forums) do
    thread
    |> thread_changeset(attrs, forum, visible_forums)
    |> Repo.update()
  end

  @doc """
  Deletes a Thread.

  ## Examples

      iex> delete_thread(thread)
      {:ok, %Thread{}}

      iex> delete_thread(thread)
      {:error, %Ecto.Changeset{}}

  """
  def delete_thread(%Thread{} = thread) do
    Repo.delete(thread)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking thread changes.

  ## Examples

      iex> change_thread(thread)
      %Ecto.Changeset{source: %Thread{}}

  """
  def change_thread(%Thread{} = thread, forum \\ nil, visible_forums \\ []) do
    thread_changeset(thread, %{}, forum, visible_forums)
  end

  alias Cforum.Forums.Messages

  def preview_thread(attrs, user, forum, visible_forums) do
    changeset =
      %Thread{created_at: Timex.now()}
      |> Thread.changeset(attrs, forum, visible_forums)

    thread = Ecto.Changeset.apply_changes(changeset)
    {message, msg_changeset} = Messages.preview_message(attrs, user, visible_forums, thread)

    forum = Enum.find(visible_forums, &(&1.forum_id == message.forum_id))

    thread = %Thread{
      thread
      | forum: forum,
        forum_id: message.forum_id,
        messages: [message],
        message: message
    }

    {thread, message, msg_changeset}
  end

  defp thread_changeset(%Thread{} = thread, attrs, forum, visible_forums) do
    Thread.changeset(thread, attrs, forum, visible_forums)
  end

  @doc """
  Returns the order value itself if it is valid; returns the
  configured value for the current forum (or the global config) when
  invalid

  ## Examples

      iex> validated_ordering("ascending")
      "ascending"

      iex> validated_ordering("foo")
      "newest-first"
  """
  def validated_ordering(order, forum \\ nil) do
    if Enum.member?(~w(ascending descending newest-first), order),
      do: order,
      else: Cforum.ConfigManager.conf(forum, "sort_threads")
  end

  @doc """
  Generate a thread slug from a params map.

  ## Example

      iex> slug_from_params(%{"year" => "2017", "month" => "jan", "day" => "31", "slug" => "foo"})
      "/2017/jan/31/foo"
  """
  def slug_from_params(%{"year" => year, "month" => month, "day" => day, "slug" => slug}),
    do: "/#{year}/#{month}/#{day}/#{slug}"

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

  def get_open_closed_state(user, thread),
    do: Repo.get_by(OpenCloseState, user_id: user.user_id, thread_id: thread.thread_id)

  def open_thread(user, thread) do
    oc = get_open_closed_state(user, thread)

    if oc != nil && oc.state != "open" do
      Repo.delete(oc)
    else
      %OpenCloseState{}
      |> OpenCloseState.changeset(%{user_id: user.user_id, thread_id: thread.thread_id, state: "open"})
      |> Repo.insert()
    end
  end

  def close_thread(user, thread) do
    oc = get_open_closed_state(user, thread)

    if oc != nil && oc.state != "closed" do
      Repo.delete(oc)
    else
      %OpenCloseState{}
      |> OpenCloseState.changeset(%{user_id: user.user_id, thread_id: thread.thread_id, state: "closed"})
      |> Repo.insert()
    end
  end

  def flag_thread(thread, flag, value) do
    flags = Map.put(thread.flags, flag, value)

    thread
    |> Ecto.Changeset.change(flags: flags)
    |> Repo.update()
  end

  def flag_thread_no_archive(user, thread) do
    System.audited("flag-no-archive", user, fn ->
      flag_thread(thread, "no-archive", "yes")
    end)
  end

  def add_to_cache({:ok, %{thread_id: tid}} = val) do
    add_to_cache_by_tid(tid)
    val
  end

  def add_to_cache({:ok, %{thread_id: tid}, _} = val) do
    add_to_cache_by_tid(tid)
    val
  end

  def add_to_cache(%{thread_id: tid} = val) do
    add_to_cache_by_tid(tid)
    val
  end

  def add_to_cache(val), do: val

  def refresh_cached_thread(%{thread_id: tid} = val) do
    refresh_cached_thread_by_tid(tid)
    val
  end

  def refresh_cached_thread({:ok, %{thread_id: tid}} = val) do
    refresh_cached_thread_by_tid(tid)
    val
  end

  def refresh_cached_thread(v), do: v

  def add_to_cache_by_tid(tid) do
    thread = get_thread!(tid)
    Caching.update(:cforum, :threads, &[thread | &1])
  end

  def refresh_cached_thread_by_tid(tid) do
    thread = get_thread!(tid)

    Caching.update(:cforum, :threads, fn threads ->
      Enum.map(threads, fn
        %Thread{thread_id: ^tid} -> thread
        thread -> thread
      end)
    end)
  end
end
