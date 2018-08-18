defmodule Cforum.Forums.ArchiverJob do
  alias Cforum.Repo
  alias Cforum.Forums
  alias Cforum.Forums.{Threads, Thread, Message, Subscription, OpenCloseState, InvisibleThread}
  alias Cforum.System
  alias Cforum.Search

  import Ecto.{Query, Changeset}, warn: false

  def archive do
    Forums.list_forums()
    |> Enum.each(&archive_for_forum/1)
  end

  defp archive_for_forum(forum) do
    archive_max_messages_per_thread(forum)
    archive_max_threads_per_forum(forum)
  end

  defp archive_max_messages_per_thread(forum) do
    max_messages = Cforum.ConfigManager.conf(forum, "max_messages_per_thread", :int)

    from(thread in Thread,
      where:
        thread.forum_id == ^forum.forum_id and thread.archived == false and
          thread.thread_id in fragment(
            "SELECT threads.thread_id FROM threads INNER JOIN messages USING(thread_id) WHERE archived = false AND threads.forum_id = ? GROUP BY thread_id HAVING COUNT(*) > ?",
            ^forum.forum_id,
            ^max_messages
          )
    )
    |> Repo.all()
    |> Repo.preload([:messages])
    |> Enum.each(&archive_thread/1)
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
        t.forum_id == ^forum.forum_id and t.archived == false and
          t.thread_id in fragment(
            "SELECT threads.thread_id FROM threads INNER JOIN messages USING(thread_id) WHERE threads.forum_id = ? AND archived = false GROUP BY threads.thread_id ORDER BY MAX(messages.message_id) LIMIT ?",
            ^forum.forum_id,
            ^limit
          )
    )
    |> Repo.all()
    |> Repo.preload([:messages])
    |> Enum.each(&archive_thread/1)
  end

  defp archive_thread(%Thread{flags: %{"no-archive" => "yes"}} = thread) do
    System.audited("destroy", nil, fn ->
      Threads.delete_thread(thread)

      case Search.get_document_by_reference_id(thread.thread_id) do
        {:ok, document} ->
          Search.delete_document(document)

        _ ->
          nil
      end

      {:ok, thread}
    end)
  end

  defp archive_thread(thread) do
    System.audited("archive", nil, fn ->
      thread
      |> change(%{archived: true})
      |> Repo.update()
      |> maybe_set_ip_nil()
      |> maybe_remove_subscriptions()
      |> maybe_remove_open_close_state()
      |> maybe_remove_invisible_threads()
    end)
  end

  defp maybe_set_ip_nil({:error, _} = retval), do: retval

  defp maybe_set_ip_nil({:ok, thread}) do
    from(m in Message, where: m.thread_id == ^thread.thread_id)
    |> Repo.update_all(set: [ip: nil])

    {:ok, thread}
  end

  defp maybe_remove_subscriptions({:error, _} = retval), do: retval

  defp maybe_remove_subscriptions({:ok, thread}) do
    mids = Enum.map(thread.messages, & &1.message_id)

    from(s in Subscription, where: s.message_id in ^mids)
    |> Repo.delete_all()

    {:ok, thread}
  end

  defp maybe_remove_open_close_state({:error, _} = retval), do: retval

  defp maybe_remove_open_close_state({:ok, thread}) do
    from(oc in OpenCloseState, where: oc.thread_id == ^thread.thread_id)
    |> Repo.delete_all()

    {:ok, thread}
  end

  defp maybe_remove_invisible_threads({:error, _} = retval), do: retval

  defp maybe_remove_invisible_threads({:ok, thread}) do
    from(iv in InvisibleThread, where: iv.thread_id == ^thread.thread_id)
    |> Repo.delete_all()

    {:ok, thread}
  end
end
