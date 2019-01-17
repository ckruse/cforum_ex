defmodule Cforum.Forums.Stats do
  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Forums.{Thread, Threads, Message}
  alias Cforum.Forums.ForumStat

  def threads_for_overview(current_user, visible_forums, opts \\ []) do
    Enum.reduce(visible_forums, {%{}, nil}, fn f, {acc, latest} ->
      {threads, latest_message} = get_latest(current_user, f, latest, opts)
      {Map.put(acc, f.forum_id, threads), latest_message}
    end)
  end

  defp get_latest(current_user, f, latest, opts) do
    defaults = [limit: 3, order: "newest-first", sticky: nil, omit: [:open_close, :subscriptions, :interesting, :read]]
    opts = Keyword.merge(defaults, opts)

    {_, threads} = Threads.list_threads(f, nil, current_user, opts)

    threads =
      Enum.map(threads, fn t ->
        attribs = set_latest_and_first_unread(t)
        %Thread{t | attribs: attribs}
      end)

    maybe_new_latest = List.first(threads)

    latest_message = get_latest_message(latest, maybe_new_latest)

    {threads, latest_message}
  end

  defp get_latest_message(nil, nil), do: nil
  defp get_latest_message(latest, nil) when not is_nil(latest), do: latest
  defp get_latest_message(nil, maybe_new_latest) when not is_nil(maybe_new_latest), do: maybe_new_latest

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
      |> Cforum.Forums.Tags.get_tags_by_ids()

    Enum.reduce(tags, [], fn {tag_id, cnt}, acc ->
      tag = Enum.find(records, &(&1.tag_id == tag_id))
      [%{tag: tag, cnt: cnt} | acc]
    end)
    |> Enum.reverse()
  end

  defp preload_users(users) do
    records =
      Enum.map(users, fn {uid, _} -> uid end)
      |> Cforum.Accounts.Users.get_users()

    Enum.reduce(users, [], fn {uid, cnt}, acc ->
      user = Enum.find(records, &(&1.user_id == uid))
      [%{user: user, cnt: cnt} | acc]
    end)
    |> Enum.reverse()
  end
end
