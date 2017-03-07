defmodule Cforum.ThreadTreeHelper do
  alias Cforum.Thread
  alias Cforum.Message

  def sort_threads([], _, _), do: []
  def sort_threads([thread | tail], conn, thread_modifier) do
    [sort_thread(conn, thread_modifier, thread)] ++ sort_threads(tail, conn, thread_modifier)
  end

  def sort_thread(conn, modifier, thread, message \\ nil, direction \\ nil)
  def sort_thread(conn, modifier, thread, modifier, message, nil), do: sort_thread(conn, modifier, thread, message, Cforum.ConfigManager.uconf(conn, "sort_messages"))
  def sort_thread(_conn, modifier, thread, nil, direction), do: gen_thread_tree(modifier, thread, direction)

  def sort_thread(_conn, modifier, thread, message, direction) do
    messages = case direction do
                 "ascending" ->
                   Enum.sort(message.messages, &(&1.created_at <= &2.created_at))
                 _ ->
                   Enum.sort(message.messages, &(&1.created_at <= &2.created_at))
               end

    # TODO!
  end

  defp to_int(nil), do: 0
  defp to_int(v), do: v

  def gen_thread_tree(modifier, thread, direction \\ "ascending") do
    sorted_messages = Enum.sort(thread.messages, fn(a, b) ->
      cond do
        a.parent_id == b.parent_id && direction == "ascending" ->
          v = Timex.compare(a.created_at, b.created_at)
          v == -1 || v == 0

        a.parent_id == b.parent_id && direction == "descending" ->
          v = Timex.compare(a.created_at, b.created_at)
          v == 1 || v == 0

        true ->
          to_int(a.parent_id) <= to_int(b.parent_id)
      end
    end)

    # [first | rest] = sorted_messages
    # tree = build_tree(first, rest)

    #
    # this is a much better solution to build the tree
    #

    thread = if modifier != nil do
      %Thread{thread | sorted_messages: sorted_messages}
      |> modifier.()
    else
      %Thread{thread | sorted_messages: sorted_messages}
    end


    tree = thread.sorted_messages
    |> Enum.reverse
    |> Enum.reduce(%{}, fn(msg, map) ->
      msg = %Message{msg | messages: Map.get(map, msg.message_id, [])}
      Map.update(map, msg.parent_id, [msg], fn(msgs) -> [msg | msgs] end)
    end)
    |> Map.get(nil)
    |> hd

    %Thread{thread | sorted_messages: sorted_messages,
                     message: tree, tree: tree,
                     accepted: Enum.filter(sorted_messages, &(&1.flags["accepted"] == "yes"))}
  end

  # defp build_tree(root, []), do: root
  # defp build_tree(root, [node | tail]), do: build_tree(insert_node(root, node), tail)

  # defp insert_node(root = %Message{}, node) do
  #   if root.message_id == node.parent_id do
  #     new_messages = case root.messages do
  #                      nil ->
  #                        [node]
  #                      _ ->
  #                        root.messages ++ [node]
  #                    end

  #     %Message{root | messages: new_messages}
  #   else
  #     acc = case root.messages do
  #             nil -> []
  #             _ -> root.messages
  #           end

  #     %Message{root | messages: insert_node(acc, node)}
  #   end
  # end

  # defp insert_node(root, node) do
  #   Enum.map(root, fn(x) -> insert_node(x, node) end)
  # end


  # def visualize_tree(node, level \\ 0)
  # def visualize_tree(nil, _), do: nil
  # def visualize_tree([], _), do: nil

  # def visualize_tree(node = %Message{}, level) do
  #   IO.puts String.duplicate("-", level) <> " " <> node.author
  #   visualize_tree(node.messages, level + 1)
  # end

  # def visualize_tree([head | nodes], level) do
  #   visualize_tree(head, level)
  #   visualize_tree(nodes, level)
  # end
end
