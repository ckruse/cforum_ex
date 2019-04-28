defmodule Cforum.Messages.MessageCaching do
  alias Cforum.Repo
  alias Cforum.Caching
  alias Cforum.Messages
  alias Cforum.Threads.Thread
  alias Cforum.Messages.Message

  def update_cached_message({:ok, %{message_id: mid}} = val) do
    update_cached_message_by_mid(mid)
    val
  end

  def update_cached_message(%{message_id: mid} = val) do
    update_cached_message_by_mid(mid)
    val
  end

  def update_cached_message(val), do: val

  def update_cached_message({:ok, %{thread_id: tid, message_id: mid}} = val, fun) do
    update_cached_message_by_tid_and_mid(tid, mid, fun)
    val
  end

  def update_cached_message(%{thread_id: tid, message_id: mid} = val, fun) do
    update_cached_message_by_tid_and_mid(tid, mid, fun)
    val
  end

  def update_cached_message_by_mid(mid) do
    msg =
      mid
      |> Messages.get_message!(view_all: true)
      |> Repo.preload(Message.default_preloads())

    Caching.update(:cforum, :threads, fn threads ->
      {_, thread} = Enum.find(threads, fn {_, thread} -> thread.thread_id == msg.thread_id end)
      thread = replace_message(thread, msg)

      Map.put(threads, thread.slug, thread)
    end)
  end

  def update_cached_message_by_tid_and_mid(tid, mid, fun) do
    Caching.update(:cforum, :threads, fn threads ->
      {_, thread} = Enum.find(threads, fn {_, thread} -> thread.thread_id == tid end)
      thread = replace_message(thread, mid, fun)

      Map.put(threads, thread.slug, thread)
    end)
  end

  defp replace_message(%Thread{messages: messages} = thread, %Message{message_id: mid} = msg) do
    messages =
      for message <- messages do
        if message.message_id == mid,
          do: msg,
          else: message
      end

    %Thread{thread | messages: messages}
  end

  defp replace_message(%Thread{messages: messages} = thread, mid, fun) do
    messages =
      for message <- messages do
        if message.message_id == mid,
          do: fun.(message),
          else: message
      end

    %Thread{thread | messages: messages}
  end
end
