defmodule Cforum.Jobs.NotificationMailerJobTest do
  use Cforum.DataCase, async: true

  import Swoosh.TestAssertions

  setup do
    user = insert(:user, admin: true)
    {:ok, user: user}
  end

  describe "priv_message" do
    setup %{user: user} do
      pm = insert(:priv_message, recipient: user, owner: user)
      {:ok, priv_message: pm}
    end

    test "it sends a notification mail", %{priv_message: pm, user: user} do
      Cforum.Jobs.NotificationMailerJob.enqueue_for_pm(pm, user)
      assert %{success: 1, failure: 0} == Oban.drain_queue(:mails)
      assert_email_sent(to: {user.username, user.email})
    end
  end

  describe "moderation_queue" do
    setup do
      forum = insert(:forum)
      thread = insert(:thread, forum: forum)
      message = insert(:message, thread: thread, forum: forum)
      entry = insert(:moderation_queue_entry, message: message)
      {:ok, entry: entry}
    end

    test "it sends a notification mail to moderators who chose email", %{entry: entry, user: user} do
      insert(:setting, user: user, options: %{"notify_on_flagged" => "email"})
      Cforum.Jobs.NotificationMailerJob.enqueue_for_moderation_queue_entry(entry)
      assert %{success: 1, failure: 0} == Oban.drain_queue(:mails)
      assert_email_sent(to: {user.username, user.email})
    end

    test "it doesn't sends a notification mail to moderators who chose yes", %{entry: entry, user: user} do
      insert(:setting, user: user, options: %{"notify_on_flagged" => "yes"})
      Cforum.Jobs.NotificationMailerJob.enqueue_for_moderation_queue_entry(entry)
      assert %{success: 1, failure: 0} == Oban.drain_queue(:mails)
      assert_no_email_sent()
    end

    test "it doesn't sends a notification mail to moderators who chose no", %{entry: entry, user: user} do
      insert(:setting, user: user, options: %{"notify_on_flagged" => "no"})
      Cforum.Jobs.NotificationMailerJob.enqueue_for_moderation_queue_entry(entry)
      assert %{success: 1, failure: 0} == Oban.drain_queue(:mails)
      assert_no_email_sent()
    end

    test "it doesn't sends a notification mail to moderators who didn't chose", %{entry: entry} do
      Cforum.Jobs.NotificationMailerJob.enqueue_for_moderation_queue_entry(entry)
      assert %{success: 1, failure: 0} == Oban.drain_queue(:mails)
      assert_no_email_sent()
    end
  end
end
