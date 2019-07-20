defmodule Cforum.Threads.ThreadCaching do
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Caching

  alias Cforum.Threads
  alias Cforum.Threads.Thread

  alias Cforum.Messages.Message

  alias Cforum.Accounts.User

  def cached_threads() do
    Caching.fetch(:cforum, :threads, fn ->
      from(thread in Thread, where: thread.archived == false, order_by: [desc: :created_at])
      |> Repo.all()
      |> Repo.preload(Thread.default_preloads())
      |> Repo.preload(
        messages:
          {from(m in Message, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at]),
           Message.default_preloads()}
      )
      |> Enum.reduce(%{}, fn thread, acc -> Map.put(acc, thread.slug, thread) end)
    end)
  end

  def refresh_cached_thread(%{thread_id: tid} = val) do
    refresh_cached_thread_by_tid(tid)
    val
  end

  def refresh_cached_thread({:ok, %{thread_id: tid}} = val) do
    refresh_cached_thread_by_tid(tid)
    val
  end

  def refresh_cached_thread({:ok, %{thread_id: tid}, _} = val) do
    refresh_cached_thread_by_tid(tid)
    val
  end

  def refresh_cached_thread({:ok, %{__struct__: User}} = val) do
    Caching.del(:cforum, :threads)
    val
  end

  def refresh_cached_thread(v), do: v

  def refresh_cached_thread_by_tid(tid) do
    thread = Threads.get_thread!(tid)
    Caching.update(:cforum, :threads, fn threads -> Map.put(threads, thread.slug, thread) end)
  end
end
