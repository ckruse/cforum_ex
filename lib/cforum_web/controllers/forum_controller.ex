defmodule CforumWeb.ForumController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias Cforum.Forums.Thread

  def index(conn, _params) do
    {latest_threads, newest_thread} = Enum.reduce(conn.assigns[:visible_forums], {%{}, nil}, fn(f, {acc, latest}) ->
      {_, threads} = Threads.list_threads(f, nil, conn.assigns[:current_user], limit: 3, order: "newest-first", sticky: nil)
      threads = Enum.map(threads, fn(t) ->
        latest_message = Enum.max_by(t.sorted_messages, fn(m) -> m.created_at end)
        first_unread = Enum.filter(t.sorted_messages, fn(m) -> m.attribs[:is_read] != true end)
        |> Enum.min_by(fn(m) -> m.created_at end, fn() -> nil end)

        attribs = t.attribs
        |> Map.put(:latest_message, latest_message)
        |> Map.put(:first_message, List.first(t.sorted_messages))
        |> Map.put(:first_unread, first_unread)

        %Thread{t | attribs: attribs}
      end)

      maybe_new_latest = List.first(threads)

      latest_message = cond do
        latest == nil ->
          maybe_new_latest
        Timex.after?(maybe_new_latest.latest_message, latest.latest_message) ->
          maybe_new_latest
        true ->
          latest
      end

      {Map.put(acc, f.forum_id, threads),
       latest_message}
    end)

    render(conn, "index.html", newest_thread: newest_thread, latest_threads: latest_threads)
  end
end
