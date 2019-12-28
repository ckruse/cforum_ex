defmodule Cforum.Forums.ArchiverJob do
  use Appsignal.Instrumentation.Decorators

  alias Cforum.Repo
  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.Threads.{Thread, InvisibleThread, OpenCloseState}
  alias Cforum.Messages.{Message, Subscription, ReadMessage}
  alias Cforum.System
  alias Cforum.Caching

  import Ecto.{Query, Changeset}, warn: false

  @decorate transaction(:maintenance)
  def archive do
    Forums.list_forums()
    |> Enum.each(&archive_for_forum/1)
  end

  @decorate transaction(:maintenance)
  def enforce_archiving(thread) do
    archive_thread(thread)
    |> discard_thread_cache()
  end

  defp archive_for_forum(forum) do
    archive_max_messages_per_thread(forum)
    archive_max_threads_per_forum(forum)
  end

  defp archive_max_messages_per_thread(forum) do
    max_messages = Cforum.ConfigManager.conf(forum, "max_messages_per_thread", :int)

    from(thread in Thread,
      where:
        thread.forum_id == ^forum.forum_id and thread.archived == false and thread.sticky == false and
          thread.thread_id in fragment(
            "SELECT threads.thread_id FROM threads INNER JOIN messages USING(thread_id) WHERE archived = false AND threads.forum_id = ? GROUP BY thread_id HAVING COUNT(*) > ?",
            ^forum.forum_id,
            ^max_messages
          )
    )
    |> Repo.all()
    |> Repo.preload([:messages])
    |> Enum.each(fn thread ->
      archive_thread(thread)
      |> discard_thread_cache()
    end)
  end

  defp archive_max_threads_per_forum(forum) do
    max_threads = Cforum.ConfigManager.conf(forum, "max_threads", :int)

    no_threads =
      from(t in Thread, select: count("*"), where: t.forum_id == ^forum.forum_id and t.archived == false)
      |> Repo.one()

    limit =
      if no_threads > max_threads,
        do: no_threads - max_threads,
        else: 0

    from(t in Thread,
      where:
        t.forum_id == ^forum.forum_id and t.archived == false and t.sticky == false and
          t.thread_id in fragment(
            "SELECT threads.thread_id FROM threads INNER JOIN messages USING(thread_id) WHERE threads.forum_id = ? AND archived = false GROUP BY threads.thread_id ORDER BY MAX(messages.message_id) LIMIT ?",
            ^forum.forum_id,
            ^limit
          )
    )
    |> Repo.all()
    |> Repo.preload([:messages])
    |> Enum.each(fn thread ->
      archive_thread(thread)
      |> discard_thread_cache()
    end)
  end

  defp archive_thread(%Thread{flags: %{"no-archive" => "yes"}} = thread) do
    System.audited("destroy", nil, fn ->
      Threads.delete_thread(thread)

      thread.messages
      |> Enum.map(& &1.message_id)
      |> Cforum.Search.delete_documents_by_reference_ids()

      {:ok, thread}
    end)
  end

  defp archive_thread(thread) do
    with {:ok, thread} <- System.audited("archive", nil, fn -> do_archive_thread(thread) end) do
      set_ip_nil(thread)
      remove_subscriptions(thread)
      remove_open_close_state(thread)
      remove_invisible_threads(thread)
      remove_visited_marks(thread)

      {:ok, thread}
    end
  end

  defp do_archive_thread(thread) do
    thread
    |> change(%{archived: true})
    |> Repo.update()
  end

  defp set_ip_nil(thread) do
    from(m in Message, where: m.thread_id == ^thread.thread_id)
    |> Repo.update_all(set: [ip: nil])

    {:ok, thread}
  end

  defp remove_subscriptions(thread) do
    mids = Enum.map(thread.messages, & &1.message_id)

    from(s in Subscription, where: s.message_id in ^mids)
    |> Repo.delete_all()

    {:ok, thread}
  end

  defp remove_open_close_state(thread) do
    from(oc in OpenCloseState, where: oc.thread_id == ^thread.thread_id)
    |> Repo.delete_all()

    {:ok, thread}
  end

  defp remove_invisible_threads(thread) do
    from(iv in InvisibleThread, where: iv.thread_id == ^thread.thread_id)
    |> Repo.delete_all()

    {:ok, thread}
  end

  defp remove_visited_marks(thread) do
    mids = Enum.map(thread.messages, & &1.message_id)

    from(rm in ReadMessage, where: rm.message_id in ^mids)
    |> Repo.delete_all()

    {:ok, thread}
  end

  defp discard_thread_cache({:ok, %Thread{slug: slug}} = val) do
    Caching.update(:cforum, :threads, fn threads -> Map.delete(threads, slug) end)

    val
  end

  defp discard_thread_cache(val), do: raise(inspect(val))
end
