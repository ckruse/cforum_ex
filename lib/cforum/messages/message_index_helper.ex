defmodule Cforum.Messages.IndexHelper do
  alias Cforum.Repo
  alias Cforum.Threads.{Thread, OpenCloseState}
  alias Cforum.Messages.Message

  alias Cforum.Messages.ReadMessage
  alias Cforum.Messages.InterestingMessage
  alias Cforum.Messages.Subscription
  alias Cforum.Threads.InvisibleThread

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

  defp get_open_close_state(tids, user) do
    from(
      oc_state in OpenCloseState,
      where: oc_state.user_id == ^user.user_id and oc_state.thread_id in ^tids,
      order_by: oc_state.thread_id
    )
    |> Repo.all()
    |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x.thread_id, x.state) end)
  end

  def get_invisible_state(tids, user) do
    from(invisible_thread in InvisibleThread,
      where: invisible_thread.user_id == ^user.user_id and invisible_thread.thread_id in ^tids,
      order_by: invisible_thread.thread_id
    )
    |> Repo.all()
    |> Enum.reduce(%{}, fn iv, acc -> Map.put(acc, iv.thread_id, true) end)
  end

  defp open_state(_messages, "open", _), do: "open"
  defp open_state(_messages, "closed", _), do: "closed"

  defp open_state(messages, _, opts) do
    if opts[:close_read_threads] do
      has_unread = Enum.find(messages, &(&1.attribs[:is_read] != true)) != nil
      if has_unread, do: "open", else: "closed"
    else
      opts[:open_close_default_state]
    end
  end

  defp set_message_flags(
         oc_state,
         iv_state,
         read_messages,
         interesting_messages,
         subscribed_messages,
         threads,
         opts,
         new_threads \\ []
       )

  defp set_message_flags(_, _, _, _, _, [], _, new_threads), do: new_threads

  defp set_message_flags(
         oc_state,
         iv_state,
         read_messages,
         interesting_messages,
         subscribed_messages,
         [thread | threads],
         opts,
         new_threads
       ) do
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

    new_attribs =
      thread.attribs
      |> Map.put(:open_state, open_state(messages, oc_state[thread.thread_id], opts))
      |> Map.put(:invisible, iv_state[thread.thread_id])

    set_message_flags(
      oc_state,
      iv_state,
      read_messages,
      interesting_messages,
      subscribed_messages,
      threads,
      opts,
      new_threads ++ [%Thread{thread | messages: messages, attribs: new_attribs}]
    )
  end

  def set_user_attributes(threads, nil, _), do: threads

  def set_user_attributes(threads, user, opts) do
    tids = Enum.map(threads, & &1.thread_id)
    omits = opts[:omit] || []
    includes = opts[:include] || []

    read_messages = if Enum.member?(omits, :read), do: %{}, else: get_read_messages(tids, user)
    subscribed_messages = if Enum.member?(omits, :subscriptions), do: %{}, else: get_subcribed_messages(tids, user)
    interesting_messages = if Enum.member?(omits, :interesting), do: %{}, else: get_interesting_messages(tids, user)
    oc_state = if Enum.member?(omits, :open_close), do: %{}, else: get_open_close_state(tids, user)
    invisible_state = if Enum.member?(includes, :invisible), do: get_invisible_state(tids, user), else: %{}

    set_message_flags(
      oc_state,
      invisible_state,
      read_messages,
      interesting_messages,
      subscribed_messages,
      threads,
      opts
    )
  end
end
