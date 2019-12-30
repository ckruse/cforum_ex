defmodule Cforum.Forums.Stats do
  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Threads
  alias Cforum.Messages.Message
  alias Cforum.Forums.ForumStat

  @spec threads_for_overview(%Cforum.Users.User{}, [%Cforum.Threads.Thread{}]) :: {map(), %Cforum.Threads.Thread{}}
  def threads_for_overview(current_user, all_threads) do
    latest = Enum.max_by(all_threads, &Timex.to_erl(&1.latest_message), fn -> nil end)

    recent_threads_per_forum = get_recent_threads_per_forum(all_threads)
    {latest, recent_threads_per_forum} = set_portal_infos(current_user, latest, recent_threads_per_forum)
    threads_by_forum = Enum.group_by(recent_threads_per_forum, & &1.forum_id)

    {threads_by_forum, latest}
  end

  defp first_unread(messages) do
    messages
    |> Enum.reject(& &1.attribs[:is_read])
    |> Enum.min_by(&Timex.to_erl(&1.created_at), fn -> nil end)
  end

  defp set_portal_infos(current_user, nil, threads), do: {nil, set_portal_infos(current_user, threads)}

  defp set_portal_infos(current_user, latest, threads) do
    [latest | threads] = set_portal_infos(current_user, [latest | threads])
    {latest, threads}
  end

  defp set_portal_infos(current_user, threads) do
    Threads.apply_user_infos(threads, current_user, omit: [:open_close, :subscriptions, :interesting])
    |> Threads.build_message_trees("ascending")
    |> Enum.map(fn thread ->
      attribs =
        thread.attribs
        |> Map.put(:latest_message, Enum.max_by(thread.sorted_messages, &Timex.to_erl(&1.created_at)))
        |> Map.put(:first_message, List.first(thread.sorted_messages))
        |> Map.put(:first_unread, first_unread(thread.sorted_messages))

      Map.put(thread, :attribs, attribs)
    end)
  end

  defp get_recent_threads_per_forum(all_threads, nthreads \\ 3) do
    all_threads
    |> Threads.sort_threads("newest-first", ignore_sticky: true)
    |> Enum.reduce(%{}, fn t, acc ->
      if Map.has_key?(acc, t.forum_id) && length(acc[t.forum_id]) >= nthreads,
        do: acc,
        else: Map.update(acc, t.forum_id, [t], &(&1 ++ [t]))
    end)
    |> Map.values()
    |> List.flatten()
  end

  def forum_stats_overall(forum, visible_forums) do
    stats =
      from(
        stat in ForumStat,
        select: {fragment("DATE_TRUNC('month', moment)"), fragment("SUM(threads)"), fragment("SUM(messages)")},
        where: fragment("DATE_TRUNC('month', moment) < DATE_TRUNC('month', NOW())"),
        group_by: fragment("1"),
        order_by: fragment("1")
      )
      |> set_forum_id_or_visible_forums(forum, visible_forums)
      |> Repo.all()

    {no_threads, no_messages} =
      stats
      |> Enum.reduce({0, 0}, fn {_, threads, messages}, {no_threads, no_messages} ->
        {no_threads + threads, no_messages + messages}
      end)

    {stats, no_threads, no_messages}
  end

  defp set_forum_id_or_visible_forums(query, nil, visible_forums) do
    forum_ids = Enum.map(visible_forums, & &1.forum_id)
    from(fs in query, where: fs.forum_id in ^forum_ids)
  end

  defp set_forum_id_or_visible_forums(query, forum, _),
    do: from(fs in query, where: fs.forum_id == ^forum.forum_id)

  def user_stats(forum, visible_forums, starts, ends) do
    from(
      msg in Message,
      select: {fragment("DATE_TRUNC('month', created_at) AS moment"), fragment("COUNT(DISTINCT author) cnt")},
      where: msg.created_at >= ^starts and msg.created_at <= ^ends,
      group_by: fragment("1")
    )
    |> set_forum_id_or_visible_forums(forum, visible_forums)
    |> Repo.all()
  end

  def forum_state(forum, visible_forums, :today) do
    starts = Timex.beginning_of_day(Timex.now())
    ends = Timex.end_of_day(starts)
    forum_state(forum, starts, ends, visible_forums)
  end

  def forum_state(forum, visible_forums, :last_week) do
    starts = Timex.beginning_of_day(Timex.subtract(Timex.now(), Timex.Duration.from_days(7)))
    ends = Timex.end_of_day(starts)
    forum_state(forum, starts, ends, visible_forums)
  end

  def forum_state(forum, visible_forums, :week) do
    ends = Timex.now()
    starts = Timex.beginning_of_day(Timex.subtract(ends, Timex.Duration.from_days(7)))
    forum_state(forum, starts, ends, visible_forums)
  end

  def forum_state(forum, visible_forums, :month) do
    ends = Timex.now()
    starts = Timex.beginning_of_day(Timex.subtract(ends, Timex.Duration.from_days(30)))
    forum_state(forum, starts, ends, visible_forums)
  end

  def forum_state(forum, visible_forums, :year) do
    ends = Timex.now()
    starts = Timex.beginning_of_day(Timex.subtract(ends, Timex.Duration.from_days(360)))
    forum_state(forum, starts, ends, visible_forums)
  end

  def forum_state(forum, starts, ends, visible_forums) do
    num_threads_messages =
      from(
        msg in Message,
        select: %{
          msgs: fragment("COUNT(*) as msgs"),
          threads: fragment("COUNT(DISTINCT thread_id) as threads"),
          num_users: fragment("COUNT(DISTINCT author) AS num_users")
        },
        where: msg.deleted == false and msg.created_at >= ^starts and msg.created_at <= ^ends
      )
      |> set_forum_id_or_visible_forums(forum, visible_forums)
      |> Repo.one()

    tags =
      from(
        msg in Message,
        inner_join: t in assoc(msg, :tags),
        select: {t.tag_id, fragment("COUNT(*) AS cnt")},
        where: msg.created_at >= ^starts and msg.created_at <= ^ends and msg.deleted == false,
        group_by: t.tag_id,
        order_by: fragment("2 DESC"),
        limit: 5
      )
      |> set_forum_id_or_visible_forums(forum, visible_forums)
      |> Repo.all()
      |> preload_tags()

    users =
      from(
        msg in Message,
        select: {msg.user_id, fragment("COUNT(*) AS cnt")},
        where:
          msg.created_at >= ^starts and msg.created_at <= ^ends and msg.deleted == false and not is_nil(msg.user_id),
        group_by: msg.user_id,
        order_by: fragment("COUNT(*) DESC"),
        limit: 5
      )
      |> set_forum_id_or_visible_forums(forum, visible_forums)
      |> Repo.all()
      |> preload_users

    %{
      users: users,
      tags: tags,
      threads: num_threads_messages[:threads],
      messages: num_threads_messages[:msgs],
      num_users: num_threads_messages[:num_users]
    }
  end

  defp preload_tags(tags) do
    records =
      Enum.map(tags, fn {tag_id, _} -> tag_id end)
      |> Cforum.Messages.Tags.get_tags_by_ids()

    Enum.reduce(tags, [], fn {tag_id, cnt}, acc ->
      tag = Enum.find(records, &(&1.tag_id == tag_id))
      [%{tag: tag, cnt: cnt} | acc]
    end)
    |> Enum.reverse()
  end

  defp preload_users(users) do
    records =
      Enum.map(users, fn {uid, _} -> uid end)
      |> Cforum.Users.get_users()

    Enum.reduce(users, [], fn {uid, cnt}, acc ->
      user = Enum.find(records, &(&1.user_id == uid))
      [%{user: user, cnt: cnt} | acc]
    end)
    |> Enum.reverse()
  end
end
