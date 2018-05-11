defmodule Cforum.Forums.Stats do
  alias Cforum.Forums.Thread
  alias Cforum.Forums.Threads

  def threads_for_overview(current_user, visible_forums) do
    Enum.reduce(visible_forums, {%{}, nil}, fn f, {acc, latest} ->
      {threads, latest_message} = get_latest(current_user, f, latest)
      {Map.put(acc, f.forum_id, threads), latest_message}
    end)
  end

  defp get_latest(current_user, f, latest) do
    {_, threads} = Threads.list_threads(f, nil, current_user, limit: 3, order: "newest-first", sticky: nil)

    threads =
      Enum.map(threads, fn t ->
        attribs = set_latest_and_first_unread(t)
        %Thread{t | attribs: attribs}
      end)

    maybe_new_latest = List.first(threads)

    latest_message = get_latest_message(latest, maybe_new_latest)

    {threads, latest_message}
  end

  defp get_latest_message(nil, maybe_new_latest), do: maybe_new_latest

  defp get_latest_message(latest, maybe_new_latest) do
    if Timex.after?(maybe_new_latest.latest_message, latest.latest_message),
      do: maybe_new_latest,
      else: latest
  end

  defp set_latest_and_first_unread(t) do
    latest_message = Enum.max_by(t.sorted_messages, fn m -> m.created_at end)

    first_unread =
      t.sorted_messages
      |> Enum.filter(fn m -> m.attribs[:is_read] != true end)
      |> Enum.min_by(fn m -> m.created_at end, fn -> nil end)

    t.attribs
    |> Map.put(:latest_message, latest_message)
    |> Map.put(:first_message, List.first(t.sorted_messages))
    |> Map.put(:first_unread, first_unread)
  end
end
