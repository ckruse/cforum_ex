defmodule Cforum.Forums.Messages.IndexHelper do
  alias Cforum.Repo
  alias Cforum.Forums.Thread
  alias Cforum.Forums.Message

  alias Cforum.Forums.ReadMessage
  alias Cforum.Forums.InterestingMessage
  alias Cforum.Forums.Subscription

  import Ecto.Query

  import Cforum.Helpers

  def preload_messages(true), do: from(m in Message)
  def preload_messages(_), do: from(m in Message, where: m.deleted == false)

  def order_messages(query) do
    from(m in query, order_by: [asc: fragment("? NULLS FIRST", m.parent_id), desc: m.created_at])
  end

  defp get_read_messages(tids, user) do
    from(
      rm in ReadMessage,
      inner_join: m in assoc(rm, :message),
      where: rm.user_id == ^user.user_id and m.thread_id in ^tids,
      order_by: m.thread_id
    )
    |> Repo.all()
    |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x.message_id, true) end)
  end

  defp get_subcribed_messages(tids, user) do
    from(
      im in Subscription,
      inner_join: m in assoc(im, :message),
      where: im.user_id == ^user.user_id and m.thread_id in ^tids,
      order_by: m.thread_id
    )
    |> Repo.all()
    |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x.message_id, true) end)
  end

  defp get_interesting_messages(tids, user) do
    from(
      im in InterestingMessage,
      inner_join: m in assoc(im, :message),
      where: im.user_id == ^user.user_id and m.thread_id in ^tids,
      order_by: m.thread_id
    )
    |> Repo.all()
    |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x.message_id, true) end)
  end

  defp set_message_flags(read_messages, interesting_messages, subscribed_messages, threads, new_threads \\ [])
  defp set_message_flags(_, _, _, [], new_threads), do: new_threads

  defp set_message_flags(read_messages, interesting_messages, subscribed_messages, [thread | threads], new_threads) do
    messages =
      Enum.map(thread.messages, fn msg ->
        classes =
          msg.attribs[:classes]
          |> add_if(read_messages[msg.message_id] != nil, "visited")
          |> add_if(subscribed_messages[msg.message_id] != nil, "subscribed")
          |> add_if(interesting_messages[msg.message_id] != nil, "interesting")

        new_attribs =
          msg.attribs
          |> Map.put(:is_read, read_messages[msg.message_id] != nil)
          |> Map.put(:is_subscribed, subscribed_messages[msg.message_id] != nil)
          |> Map.put(:is_interesting, interesting_messages[msg.message_id] != nil)
          |> Map.put(:classes, classes)

        %Message{msg | attribs: new_attribs}
      end)

    set_message_flags(
      read_messages,
      interesting_messages,
      subscribed_messages,
      threads,
      new_threads ++ [%Thread{thread | messages: messages}]
    )
  end

  def set_user_attributes(threads, nil), do: threads

  def set_user_attributes(threads, user) do
    tids = Enum.map(threads, & &1.thread_id)

    read_messages = get_read_messages(tids, user)
    subscribed_messages = get_subcribed_messages(tids, user)
    interesting_messages = get_interesting_messages(tids, user)

    set_message_flags(read_messages, interesting_messages, subscribed_messages, threads)
  end
end
