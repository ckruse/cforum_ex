defmodule CforumWeb.Plug.LoadUserInfoData do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads some meta information
  for signed in users (e.g. the count of unread PMs and notifications)
  """

  alias Cforum.Accounts
  alias Accounts.Notifications
  alias Accounts.PrivMessages
  alias Cforum.Forums
  alias Cforum.Messages.ReadMessages
  alias Cforum.ModerationQueue
  alias Cforum.Cites

  def init(opts), do: opts

  def call(%{assigns: %{current_user: user, is_moderator: is_mod, visible_forums: forums}} = conn, _opts)
      when not is_nil(user) do
    {num_threads, num_messages} = ReadMessages.count_unread_messages(user, forums)
    undeceided_cites = Cites.count_undecided_cites(user)

    undecided_moderation_queue_entries =
      if is_mod do
        forums = Forums.list_forums_by_permission(user, Accounts.ForumGroupPermission.moderate())
        ModerationQueue.count_entries(forums, true)
      else
        0
      end

    conn
    |> Plug.Conn.assign(:unread_notifications, Notifications.count_notifications(user, true))
    |> Plug.Conn.assign(:unread_mails, PrivMessages.count_priv_messages(user, true))
    |> Plug.Conn.assign(:unread_threads, num_threads)
    |> Plug.Conn.assign(:unread_messages, num_messages)
    |> Plug.Conn.assign(:undecided_cites, undeceided_cites)
    |> Plug.Conn.assign(:undecided_moderation_queue_entries, undecided_moderation_queue_entries)
  end

  def call(conn, _opts), do: conn
end
