defmodule Cforum.Threads do
  @moduledoc """
  The boundary for the Threads system.
  """

  import Ecto.{Query, Changeset}, warn: false

  alias Cforum.Repo
  alias Cforum.System

  alias Cforum.Accounts.User

  alias Cforum.Threads.Thread
  alias Cforum.Threads.InvisibleThread
  alias Cforum.Threads.ThreadHelpers
  alias Cforum.Threads.ThreadCaching

  alias Cforum.Messages
  alias Cforum.Messages.Message
  alias Cforum.Messages.MessageHelpers

  @doc """
  Returns the list of unarchived threads.

  ## Examples

      iex> list_threads()
      [%Thread{}, ...]

  """
  def list_threads(forum, visible_forums)
  def list_threads(forum, _) when not is_nil(forum), do: list_threads(nil, [forum])

  def list_threads(_, forums) do
    threads = ThreadCaching.cached_threads()

    if forums == nil || forums == [] do
      Map.values(threads)
    else
      forum_ids = Enum.map(forums, & &1.forum_id)

      for {_, thread} <- threads, thread.forum_id in forum_ids, do: thread
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
      thread = Map.put(thread, :messages, Enum.reject(thread.messages, &MessageHelpers.message_deleted?/1))

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
    do: Cforum.Messages.IndexHelper.set_user_attributes([thread], user, opts) |> List.first()

  def apply_user_infos(threads, user, opts),
    do: Cforum.Messages.IndexHelper.set_user_attributes(threads, user, opts)

  def apply_highlights(%Thread{} = thread, conn),
    do: Cforum.Messages.HighlightsHelper.apply_highlights([thread], conn) |> List.first()

  def apply_highlights(threads, conn),
    do: Cforum.Messages.HighlightsHelper.apply_highlights(threads, conn)

  def build_message_trees(threads, message_order) do
    for thread <- threads do
      build_message_tree(thread, message_order)
    end
  end

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
      |> ensure_found!()
      |> hd

    thread
    |> Map.put(:sorted_messages, sorted_messages)
    |> Map.put(:message, tree)
    |> Map.put(:tree, tree)
    |> Map.put(:accepted, Enum.filter(sorted_messages, &(&1.flags["accepted"] == "yes")))
  end

  def paged_thread_list(threads, page, limit, use_paging \\ true)
  def paged_thread_list(threads, _, _, false), do: threads

  def paged_thread_list(threads, page, limit, _) do
    {sticky, normal} =
      Enum.reduce(threads, {[], []}, fn
        %Thread{sticky: true} = thread, {sticky, normal} -> {[thread | sticky], normal}
        thread, {sticky, normal} -> {sticky, [thread | normal]}
      end)

    limit = limit - length(sticky)

    Enum.concat(Enum.reverse(sticky), normal |> Enum.reverse() |> Enum.slice(page * limit, limit))
  end

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
    do: Enum.filter(threads, &(length(&1.messages) <= 1 && MessageHelpers.open?(List.first(&1.messages))))

  def ensure_found!(threads) when threads == [] or threads == nil, do: raise(Ecto.NoResultsError, queryable: Thread)
  def ensure_found!(threads), do: threads

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

  def get_thread(id) do
    Thread
    |> Repo.get_by(thread_id: id)
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
        |> ThreadHelpers.set_forum_id(visible_forums, forum)
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
    threads = ThreadCaching.cached_threads()
    thread = get_thread_by_slug_from_cache(threads[slug], forum, visible_forums, slug)

    case thread do
      nil -> raise Ecto.NoResultsError, queryable: Thread
      thread -> thread
    end
  end

  defp get_thread_by_slug_from_cache(nil, forum, visible_forums, slug) do
    from(thread in Thread, where: thread.slug == ^slug, order_by: [desc: :created_at])
    |> ThreadHelpers.set_forum_id(visible_forums, forum)
    |> Repo.one()
    |> Repo.preload(Thread.default_preloads())
    |> Repo.preload(
      messages:
        {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at]),
         Message.default_preloads()}
    )
  end

  defp get_thread_by_slug_from_cache(thread, nil, visible_forums, _) do
    if Enum.find(visible_forums, &(&1.forum_id == thread.forum_id)),
      do: thread,
      else: nil
  end

  defp get_thread_by_slug_from_cache(thread, forum, _, _) do
    if thread.forum_id == forum.forum_id,
      do: thread,
      else: nil
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
            create_message(attrs, user, visible_forums, thread, Keyword.merge(opts, notify: false))

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
    |> ThreadCaching.refresh_cached_thread()
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
    Cforum.Messages.NotifyUsersMessageJob.notify_users_about_new_thread(thread, message)

    CforumWeb.Endpoint.broadcast!("forum:#{message.forum_id}", "new_message", %{
      thread: thread,
      message: message,
      forum: Cforum.Forums.get_forum!(message.forum_id)
    })

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
    |> ThreadCaching.refresh_cached_thread()
  end

  def move_thread(%User{} = user, %Thread{} = thread, forum_id, visible_forums, url_generator) do
    forum = Cforum.Forums.get_forum!(forum_id)

    thread
    |> change_thread(forum, visible_forums)
    |> do_move_thread(user, forum, url_generator)
  end

  defp do_move_thread(%Ecto.Changeset{valid?: false} = changeset, _user, _forum, _url_generator), do: changeset

  defp do_move_thread(%Ecto.Changeset{valid?: true, data: thread}, user, forum, url_generator) do
    System.audited("move", user, fn ->
      from(thr in Thread, where: thr.thread_id == ^thread.thread_id)
      |> Repo.update_all(set: [forum_id: forum.forum_id])

      from(m in Message, where: m.thread_id == ^thread.thread_id)
      |> Repo.update_all(set: [forum_id: forum.forum_id])

      Enum.each(thread.messages, fn msg ->
        [old_url, new_url] = url_generator.(forum, thread, msg)

        from(r in Cforum.System.Redirection, where: r.path == ^new_url)
        |> Repo.delete_all()

        %Cforum.System.Redirection{}
        |> Ecto.Changeset.change(%{path: old_url, destination: new_url, http_status: 301})
        |> Repo.insert!()
      end)

      thread = get_thread!(thread.thread_id)
      {:ok, thread}
    end)
    |> ThreadCaching.refresh_cached_thread()
  end

  def split_thread(user, thread, message, attrs, visible_forums, url_generator, opts \\ []) do
    ret =
      System.audited("split", user, fn ->
        message
        |> Messages.update_message(attrs, user, visible_forums, opts)
        |> split_thread(thread, message, visible_forums, url_generator)
      end)

    with {:ok, new_thread} <- ret do
      ThreadCaching.refresh_cached_thread(thread)
      ThreadCaching.refresh_cached_thread(new_thread)

      refreshed_thread = get_thread!(new_thread.forum, visible_forums, new_thread.thread_id)
      message = Messages.get_message_from_mid!(refreshed_thread, message.message_id)

      {:ok, refreshed_thread, message}
    end
  end

  defp split_thread({:ok, new_message}, thread, message, visible_forums, url_generator) do
    ret =
      %Thread{latest_message: DateTime.truncate(Timex.now(), :second)}
      |> Thread.changeset(%{subject: new_message.subject, forum_id: new_message.forum_id}, nil, visible_forums)
      |> Repo.insert()

    with {:ok, new_thread} <- ret do
      new_thread = Repo.preload(new_thread, [:forum])

      from(m in Message, where: m.message_id == ^message.message_id)
      |> Repo.update_all(set: [parent_id: nil])

      message_ids =
        message
        |> messages_ids_of_children()
        |> List.flatten()

      from(m in Message, where: m.message_id in ^message_ids)
      |> Repo.update_all(set: [thread_id: new_thread.thread_id])

      new_thread = Repo.preload(new_thread, [:messages])

      Enum.each(new_thread.messages, fn msg ->
        [old_url, new_url] = url_generator.(thread, new_thread, msg)

        from(r in Cforum.System.Redirection, where: r.path == ^new_url)
        |> Repo.delete_all()

        %Cforum.System.Redirection{}
        |> Ecto.Changeset.change(%{path: old_url, destination: new_url, http_status: 301})
        |> Repo.insert!()
      end)

      {:ok, new_thread}
    end
  end

  defp split_thread(val, _, _, _, _), do: val

  defp messages_ids_of_children(message),
    do: [message.message_id | Enum.map(message.messages, &messages_ids_of_children/1)]

  def mark_thread_sticky(%User{} = user, %Thread{} = thread) do
    System.audited("sticky", user, fn ->
      thread
      |> Ecto.Changeset.change(sticky: true)
      |> Repo.update()
    end)
    |> ThreadCaching.refresh_cached_thread()
  end

  def mark_thread_unsticky(%User{} = user, %Thread{} = thread) do
    System.audited("unsticky", user, fn ->
      thread
      |> Ecto.Changeset.change(sticky: false)
      |> Repo.update()
    end)
    |> ThreadCaching.refresh_cached_thread()
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

  def flag_thread(thread, flag, value) do
    flags = Map.put(thread.flags, flag, value)

    thread
    |> Ecto.Changeset.change(flags: flags)
    |> Repo.update()
  end

  def unflag_thread(thread, flag) do
    flags = Map.delete(thread.flags, flag)

    thread
    |> Ecto.Changeset.change(flags: flags)
    |> Repo.update()
  end

  def flag_thread_no_archive(user, thread) do
    System.audited("no-archive-yes", user, fn ->
      flag_thread(thread, "no-archive", "yes")
    end)
    |> ThreadCaching.refresh_cached_thread()
  end

  def flag_thread_archive(user, thread) do
    System.audited("no-archive-no", user, fn ->
      unflag_thread(thread, "no-archive")
    end)
    |> ThreadCaching.refresh_cached_thread()
  end
end
