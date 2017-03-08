defmodule Cforum.ThreadsHelper do
  alias Cforum.Repo
  alias Cforum.Thread
  alias Cforum.Message
  alias Cforum.User

  import Cforum.ConfigManager
  import Cforum.ThreadTreeHelper
  import Cforum.MessageIndexHelper
  import Ecto.Query

  @default_message_preloads [:user, :tags, votes: :voters]

  defp set_forum_id(query, nil, nil), do: query
  defp set_forum_id(query, nil, visible_forums) when visible_forums != nil do
    fids = Enum.map(visible_forums, &(&1.forum_id))
    from thread in query,
      where: thread.forum_id in (^fids)
  end
  defp set_forum_id(query, forum, _) do
    from thread in query,
      where: thread.forum_id == ^forum.forum_id
  end

  defp set_view_all(query, true), do: query
  defp set_view_all(query, _view_all) do
    from thread in query,
      where: thread.deleted == false
  end

  defp set_ordering(query, order) do
    from thread in query,
      order_by: ^order
  end

  defp hide_read_threads(query, user, true) when user != nil do
    from thread in query,
      where: fragment("EXISTS(SELECT a.message_id FROM messages a LEFT JOIN read_messages b ON a.message_id = b.message_id AND b.user_id = ? WHERE thread_id = ? AND read_message_id IS NULL AND a.deleted = false) OR EXISTS(SELECT a.message_id FROM messages AS a INNER JOIN interesting_messages USING(message_id) WHERE thread_id = ? AND interesting_messages.user_id = ? AND deleted = false)", ^user.user_id, thread.thread_id, thread.thread_id, ^user.user_id)
  end
  defp hide_read_threads(query, _, _), do: query

  defp leave_out_invisible(query, nil, _), do: query
  defp leave_out_invisible(query, _, true), do: query
  defp leave_out_invisible(query, user, _) do
    from thread in query,
      where: fragment("NOT EXISTS(SELECT thread_id FROM invisible_threads WHERE user_id = ? AND invisible_threads.thread_id = ?)", ^user.user_id, thread.thread_id)
  end

  defp only_wo_answer(query, true, visible_forums) do
    fids = Enum.map(visible_forums, &(&1.forum_id))
    from thread in query,
      where: thread.thread_id in (fragment("SELECT thread_id FROM threads INNER JOIN messages USING(thread_id) WHERE archived = false AND threads.deleted = false AND messages.deleted = false AND threads.forum_id = ANY(?) AND (messages.flags->'no-answer-admin' = 'no' OR (messages.flags->'no-answer-admin') IS NULL) AND (messages.flags->'no-answer' = 'no' OR (messages.flags->'no-answer') IS NULL) GROUP BY threads.thread_id HAVING COUNT(*) <= 1", ^fids))
  end
  defp only_wo_answer(query, _, _), do: query

  def get_threads(forum, user, visible_forums, opts \\ []) do
    defaults = [sticky: false, view_all: false, hide_read_threads: false,
                only_wo_answer: false, thread_conditions: %{}]
    opts = Keyword.merge(defaults, opts)

    threads_query = from(thread in Thread,
      where: thread.archived == false and thread.sticky == false)
    |> set_forum_id(forum, visible_forums)
    |> set_view_all(opts[:view_all])
    |> hide_read_threads(user, opts[:hide_read_threads])
    |> leave_out_invisible(user, opts[:view_all])
    |> only_wo_answer(opts[:only_wo_answer], visible_forums)

    sticky_threads_query = case opts[:sticky] do
                             true ->
                               from(thread in Thread,
                                 where: thread.archived == false and thread.sticky == true,
                                 inner_join: m in Message, on: m.thread_id == thread.thread_id,
                                 left_join: u in User, on: u.user_id == m.user_id)
                               |> set_forum_id(forum, visible_forums)
                               |> set_view_all(opts[:view_all])
                               |> hide_read_threads(user, opts[:hide_read_threads])
                               |> leave_out_invisible(user, opts[:view_all])
                               |> only_wo_answer(opts[:only_wo_answer], visible_forums)

                             _ ->
                               nil
                           end

    {sticky_threads_query, threads_query}
  end

  def index_threads(conn, opts \\ []) do
    opts = Keyword.merge([sticky: true, page: nil, limit: nil,
                          gen_tree: true, only_sql: false,
                          only_wo_answer: false, page: 0, limit: 50], opts)

    user = conn.assigns[:current_user]

    {set_cookie, ordering} = cond do
      conn.params["order"] != "" && conn.params["order"] != nil ->
        {user == nil, conn.params["order"]}
      conn.cookies["cf_order"] != "" && conn.cookies["cf_order"] != nil && user == nil ->
        {false, conn.cookies["order"]}
      true ->
        {false, uconf(conn, "sort_threads")}
    end

    ordering = if Enum.member?(~w(ascending descending newest-first), ordering), do: ordering, else: "ascending"

    # TODO
    #conn = if set_cookie, do: put_resp_cookie(conn, "cf_order", ordering, max_age: 360*24*60*60), else: conn

    order = case ordering do
              "descending" -> [desc: :created_at]
              "newest-first" -> [desc: :latest_message]
              _ -> [asc: :created_at]
            end

    {sticky_threads_query, threads_query} = get_threads(conn.assigns[:current_forum], user,
      conn.assigns[:visible_forums], sticky: opts[:sticky], view_all: conn.assigns[:view_all],
      hide_read_threads: uconf(conn, "hide_read_threads") == "yes" && conn.params["srt"] == "yes",
      only_wo_answer: conn.params["only_wo_answer"] != nil)

    sticky_threads = case opts[:sticky] do
                       true ->
                         from(thread in sticky_threads_query, preload: :forum)
                         |> set_ordering(order)
                         |> Repo.all()
                         |> Repo.preload(messages: {preload_messages(opts[:view_all]) |> order_messages(), @default_message_preloads})
                         |> set_user_attributes(user)
                         |> sort_threads(conn, opts[:thread_modifier])

                       _ ->
                         []
                     end

    {all_threads_count, threads_query} = if uconf(conn, "page_messages") == "yes" do
      page = if is_bitstring(opts[:page]), do: String.to_integer(opts[:page]), else: opts[:page]
      page = case page do
               p when p == nil or p < 0 -> 0
               p -> p
             end

      limit = if is_bitstring(opts[:limit]), do: String.to_integer(opts[:limit]), else: opts[:limit]
      limit = case limit do
                l when l == nil or l < 0 -> String.to_integer(conf(conn, "pagination"))
                l -> l
              end

      limit = if opts[:sticky], do: limit - length(sticky_threads), else: limit
      offset = limit * page

      all_threads_count = from(thread in threads_query, select: count(thread.thread_id, :distinct)) |> Repo.one!

      {all_threads_count, from(thread in threads_query,
          limit: ^limit,
          offset: ^offset)}
    else
      {0, threads_query}
    end

    threads = from(thread in threads_query, preload: :forum)
    |> set_ordering(order)
    |> Repo.all()
    |> Repo.preload(messages: {preload_messages(opts[:view_all]) |> order_messages(), @default_message_preloads})
    |> set_user_attributes(user)
    |> sort_threads(conn, opts[:thread_modifier])

    sticky_threads ++ threads
  end

end
