defmodule Cforum.Forums.Threads.Helper do
  alias Cforum.Repo
  alias Cforum.Forums.Thread
  alias Cforum.Forums.Message
  # alias Cforum.Accounts.User

  import Cforum.Forums.Threads.TreeHelper
  import Cforum.Forums.Messages.IndexHelper
  import Ecto.Query

  defp set_forum_id(query, nil, nil), do: query

  defp set_forum_id(query, nil, visible_forums) when visible_forums != nil do
    fids = Enum.map(visible_forums, & &1.forum_id)
    from(thread in query, where: thread.forum_id in ^fids)
  end

  defp set_forum_id(query, forum, _), do: from(thread in query, where: thread.forum_id == ^forum.forum_id)
  defp set_view_all(query, true), do: query
  defp set_view_all(query, _view_all), do: from(thread in query, where: thread.deleted == false)
  defp set_ordering(query, order), do: from(thread in query, order_by: ^order)

  defp hide_read_threads(query, user, true) when user != nil do
    from(
      thread in query,
      where:
        fragment(
          "EXISTS(SELECT a.message_id FROM messages a LEFT JOIN read_messages b ON a.message_id = b.message_id AND b.user_id = ? WHERE thread_id = ? AND read_message_id IS NULL AND a.deleted = false) OR EXISTS(SELECT a.message_id FROM messages AS a INNER JOIN interesting_messages USING(message_id) WHERE thread_id = ? AND interesting_messages.user_id = ? AND deleted = false)",
          ^user.user_id,
          thread.thread_id,
          thread.thread_id,
          ^user.user_id
        )
    )
  end

  defp hide_read_threads(query, _, _), do: query

  defp leave_out_invisible(query, user, leave_out) when is_nil(user) or leave_out == true, do: query

  defp leave_out_invisible(query, user, _) do
    from(
      thread in query,
      where:
        fragment(
          "NOT EXISTS(SELECT thread_id FROM invisible_threads WHERE user_id = ? AND invisible_threads.thread_id = ?)",
          ^user.user_id,
          thread.thread_id
        )
    )
  end

  defp only_wo_answer(query, true, visible_forums) do
    fids = Enum.map(visible_forums, & &1.forum_id)

    from(
      thread in query,
      where:
        thread.thread_id in fragment(
          "SELECT thread_id FROM threads INNER JOIN messages USING(thread_id) WHERE archived = false AND threads.deleted = false AND messages.deleted = false AND threads.forum_id = ANY(?) AND (messages.flags->'no-answer-admin' = 'no' OR (messages.flags->'no-answer-admin') IS NULL) AND (messages.flags->'no-answer' = 'no' OR (messages.flags->'no-answer') IS NULL) GROUP BY threads.thread_id HAVING COUNT(*) <= 1",
          ^fids
        )
    )
  end

  defp only_wo_answer(query, _, _), do: query

  def get_threads(forum, user, visible_forums, opts \\ []) do
    defaults = [sticky: false, view_all: false, hide_read_threads: false, only_wo_answer: false, thread_conditions: %{}]
    opts = Keyword.merge(defaults, opts)

    also_query_sticky =
      if opts[:sticky] == nil do
        from(thread in Thread, where: thread.archived == false)
      else
        from(thread in Thread, where: thread.archived == false and thread.sticky == false)
      end

    threads_query =
      also_query_sticky
      |> set_forum_id(forum, visible_forums)
      |> set_view_all(opts[:view_all])
      |> hide_read_threads(user, opts[:hide_read_threads])
      |> leave_out_invisible(user, opts[:view_all])
      |> only_wo_answer(opts[:only_wo_answer], visible_forums)

    sticky_threads_query =
      case opts[:sticky] do
        true ->
          from(
            thread in Thread,
            where: thread.archived == false and thread.sticky == true,
            inner_join: m in Message,
            on: m.thread_id == thread.thread_id,
            left_join: u in User,
            on: u.user_id == m.user_id
          )
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

  def get_sticky_threads(_, _, _, _, false), do: []
  def get_sticky_threads(_, _, _, _, nil), do: []

  def get_sticky_threads(query, user, order, opts, true) do
    from(thread in query, preload: ^Thread.default_preloads())
    |> set_ordering(order)
    |> Repo.all()
    |> Repo.preload(messages: {preload_messages(opts[:view_all]) |> order_messages(), Message.default_preloads()})
    |> set_user_attributes(user)
    |> sort_threads(opts[:message_order], opts[:thread_modifier])
  end

  def gen_normal_threads_query(threads_query, page, per_page, sticky_len, true) do
    page = if is_bitstring(page), do: String.to_integer(page), else: page

    page =
      case page do
        p when p == nil or p < 0 -> 0
        p -> p
      end

    limit =
      if is_bitstring(per_page),
        do: String.to_integer(per_page) - sticky_len,
        else: per_page - sticky_len

    offset = limit * page

    all_threads_count =
      from(thread in threads_query, select: count(thread.thread_id, :distinct))
      |> Repo.one!()

    {all_threads_count, from(thread in threads_query, limit: ^limit, offset: ^offset)}
  end

  def gen_normal_threads_query(threads_query, _, _, _, false), do: {0, threads_query}

  def get_normal_threads(threads_query, user, order, sticky_len, opts) do
    {all_threads_count, threads_query} =
      gen_normal_threads_query(threads_query, opts[:page], opts[:limit], sticky_len, opts[:use_paging])

    threads =
      from(thread in threads_query, preload: ^Thread.default_preloads())
      |> set_ordering(order)
      |> Repo.all()
      |> Repo.preload(messages: {preload_messages(opts[:view_all]) |> order_messages(), Message.default_preloads()})
      |> set_user_attributes(user)
      |> sort_threads(opts[:message_order], opts[:thread_modifier])

    {all_threads_count, threads}
  end
end
