defmodule CforumWeb.ForumController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.Messages
  alias Cforum.Forums.Stats
  alias Cforum.ConfigManager

  def index(conn, %{"t" => tid, "m" => mid}) when not is_nil(tid) and not is_nil(mid) do
    if !Regex.match?(~r/^\d+$/, tid) || !Regex.match?(~r/^\d+$/, mid),
      do: raise(Cforum.Errors.NotFoundError, conn: conn)

    threads =
      Threads.get_threads_by_tid!(tid)
      |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))

    case threads do
      [thread] ->
        message = Messages.get_message_from_old_mid!(thread, mid)
        redirect(conn, to: Path.message_path(conn, :show, thread, message))

      threads ->
        conn
        |> put_view(CforumWeb.RedirectorView)
        |> render("redirect_archive_thread.html", threads: threads)
    end
  end

  def index(conn, _params) do
    {priv_messages, notifications} =
      if conn.assigns[:current_user] do
        {Cforum.PrivMessages.list_unread_priv_messages(conn.assigns[:current_user]),
         Cforum.Notifications.list_unread_notifications(conn.assigns[:current_user])}
      else
        {[], []}
      end

    all_threads =
      Threads.list_threads(nil, conn.assigns[:visible_forums])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all], true)
      |> Threads.reject_invisible_threads(conn.assigns[:current_user])

    {latest_threads, newest_thread} = Stats.threads_for_overview(conn.assigns[:current_user], all_threads)

    unanswered_threads =
      all_threads
      |> Threads.filter_wo_answer()
      |> Threads.sort_threads("descending")
      |> Threads.paged_thread_list(0, 3)
      |> Threads.apply_user_infos(conn.assigns[:current_user], omit: [:open_close, :subscriptions, :interesting])
      |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))

    render(
      conn,
      "index.html",
      newest_thread: newest_thread,
      latest_threads: latest_threads,
      notifications: notifications,
      priv_messages: priv_messages,
      unanswered_threads: unanswered_threads
    )
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

  def allowed?(_, action, _) when action in [:index, :stats], do: true
  def allowed?(_, _, _), do: false
end
