defmodule Cforum.Jobs.NotifyUsersMessageJobTest do
  use Cforum.DataCase

  import Swoosh.TestAssertions
  import CforumWeb.Gettext
  import Ecto.Query, warn: false

  alias Cforum.Accounts.Notifications

  alias Cforum.Repo

  setup do
    user = insert(:user)
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum, tags: [])
    tag = insert(:tag, messages: [message])

    {:ok, user: user, forum: forum, thread: thread, message: message, tag: tag}
  end

  describe "message" do
    test "sends a mention notification when unconfigured", %{user: user, thread: thread, forum: forum, tag: tag} do
      message =
        insert(:message,
          tags: [tag],
          forum: forum,
          thread: thread,
          content: "foo bar baz\n@#{user.username}",
          flags: %{"mentions" => [[user.username, user.user_id, false]]}
        )

      Cforum.Jobs.NotifyUsersMessageJob.enqueue(thread, message, "message")
      assert %{success: 1, failure: 0} == Oban.drain_queue(:background)

      notifications = Notifications.list_notifications(user)
      assert length(notifications) == 1

      n = List.first(notifications)
      assert n.otype == "message:mention"
    end

    test "sends a mention notification when configured", %{user: user, thread: thread, forum: forum, tag: tag} do
      insert(:setting, user: user, options: %{"notify_on_mention" => "yes"})

      message =
        insert(:message,
          tags: [tag],
          content: "foo bar baz\n@#{user.username}",
          thread: thread,
          forum: forum,
          flags: %{"mentions" => [[user.username, user.user_id, false]]}
        )

      Cforum.Jobs.NotifyUsersMessageJob.enqueue(thread, message, "message")
      assert %{success: 1, failure: 0} == Oban.drain_queue(:background)

      notifications = Notifications.list_notifications(user)
      assert length(notifications) == 1

      n = List.first(notifications)
      assert n.otype == "message:mention"
    end

    test "doesn't send a mention notification when configured", %{user: user, thread: thread, forum: forum, tag: tag} do
      insert(:setting, user: user, options: %{"notify_on_mention" => "no"})

      message =
        insert(:message,
          tags: [tag],
          content: "foo bar baz\n@#{user.username}",
          thread: thread,
          forum: forum,
          flags: %{"mentions" => [[user.username, user.user_id, false]]}
        )

      Cforum.Jobs.NotifyUsersMessageJob.enqueue(thread, message, "message")
      assert %{success: 1, failure: 0} == Oban.drain_queue(:background)

      notifications = Notifications.list_notifications(user)
      assert Enum.empty?(notifications)
    end

    test "sends an email notification", %{user: user, thread: thread, forum: forum, tag: tag} do
      insert(:setting, user: user, options: %{"notify_on_mention" => "email"})

      message =
        insert(:message,
          tags: [tag],
          content: "foo bar baz\n@#{user.username}",
          thread: thread,
          forum: forum,
          flags: %{"mentions" => [[user.username, user.user_id, false]]}
        )

      Cforum.Jobs.NotifyUsersMessageJob.enqueue(thread, message, "message")
      assert %{success: 1, failure: 0} == Oban.drain_queue(:background)

      subject =
        gettext("%{nick} mentioned you in a new message: “%{subject}”", subject: message.subject, nick: message.author)

      msg_subject = gettext("new notification: “%{subject}”", subject: subject)

      assert_email_sent(to: {user.username, user.email}, subject: msg_subject)
    end
  end

  describe "thread" do
    test "sends no notifications to users who didn't choose", %{thread: thread, message: message} do
      Cforum.Jobs.NotifyUsersMessageJob.enqueue(thread, message, "thread")
      assert %{success: 1, failure: 0} == Oban.drain_queue(:background)

      notifications = from(notification in Cforum.Accounts.Notification, select: count()) |> Repo.one()
      assert notifications == 0
    end

    test "sends no notifications to users who chose no", %{user: user, thread: thread, message: message} do
      insert(:setting, user: user, options: %{"notify_on_new_thread" => "no"})

      Cforum.Jobs.NotifyUsersMessageJob.enqueue(thread, message, "thread")
      assert %{success: 1, failure: 0} == Oban.drain_queue(:background)

      notifications = from(notification in Cforum.Accounts.Notification, select: count()) |> Repo.one()
      assert notifications == 0
    end

    test "sends notifications to users who chose yes", %{user: user, thread: thread, message: message} do
      insert(:setting, user: user, options: %{"notify_on_new_thread" => "yes"})

      Cforum.Jobs.NotifyUsersMessageJob.enqueue(thread, message, "thread")
      assert %{success: 1, failure: 0} == Oban.drain_queue(:background)

      notifications = from(notification in Cforum.Accounts.Notification, select: count()) |> Repo.one()
      assert notifications == 1
    end
  end
end
