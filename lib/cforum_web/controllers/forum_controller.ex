defmodule CforumWeb.ForumController do
  use CforumWeb, :controller

  alias Cforum.Forums.Stats

  def index(conn, _params) do
    {latest_threads, newest_thread} =
      Stats.threads_for_overview(conn.assigns[:current_user], conn.assigns[:visible_forums])

    render(conn, "index.html", newest_thread: newest_thread, latest_threads: latest_threads)
  end

  def stats(conn, _params) do
    forum = conn.assigns[:current_forum]
    # user = conn.assigns[:current_user]
    visible_forums = conn.assigns[:visible_forums]

    {stats, no_threads, no_messages} = Stats.forum_stats_overall(forum, visible_forums)
    oldest_forum = get_oldest_forum(forum, visible_forums)

    users_twelve_months =
      Stats.user_stats(forum, visible_forums, Timex.subtract(Timex.now(), Timex.Duration.from_days(360)), Timex.now())

    state = %{
      today: Stats.forum_state(forum, visible_forums, :today),
      last_week: Stats.forum_state(forum, visible_forums, :last_week),
      week: Stats.forum_state(forum, visible_forums, :week),
      month: Stats.forum_state(forum, visible_forums, :month),
      year: Stats.forum_state(forum, visible_forums, :year)
    }

    render(
      conn,
      "stats.html",
      no_threads: no_threads,
      no_messages: no_messages,
      oldest_forum: oldest_forum,
      users_twelve_months: users_twelve_months,
      stats: stats,
      state: state
    )
  end

  def get_oldest_forum(nil, []), do: nil
  def get_oldest_forum(nil, visible_forums), do: Enum.min_by(visible_forums, & &1.created_at)
  def get_oldest_forum(forum, _), do: forum
end
