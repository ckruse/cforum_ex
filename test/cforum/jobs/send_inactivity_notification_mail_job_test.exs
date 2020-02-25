defmodule Cforum.Jobs.SendInactivityNotificationMailJobTest do
  use Cforum.DataCase

  alias Cforum.Users.User
  alias Cforum.Repo

  import Swoosh.TestAssertions

  test "send mail to 1yo users with less than 25 messages" do
    date = Timex.now() |> Timex.shift(months: -13)
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -1))

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)

    assert user.inactivity_notification_sent_at
    assert_email_sent()

    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -1))
    insert_list(24, :message, user: user, thread: thread, forum: forum)

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)
    assert user.inactivity_notification_sent_at
    assert_email_sent()
  end

  test "don't send mail to 1yo users with 25 or more messages" do
    date = Timex.now() |> Timex.shift(months: -13)
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -1))
    insert_list(25, :message, user: user, thread: thread, forum: forum)
    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)
    refute user.inactivity_notification_sent_at
    refute_email_sent()
  end

  test "send mail to 2yo users with less than 50 messages" do
    date = Timex.now() |> Timex.shift(months: -25)
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -2))

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)

    assert user.inactivity_notification_sent_at
    assert_email_sent()

    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -2))
    insert_list(49, :message, user: user, thread: thread, forum: forum)

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)
    assert user.inactivity_notification_sent_at
    assert_email_sent()
  end

  test "don't send mail to 2yo users with 50 or more messages" do
    date = Timex.now() |> Timex.shift(months: -25)
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -2))
    insert_list(50, :message, user: user, thread: thread, forum: forum)
    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)
    refute user.inactivity_notification_sent_at
    refute_email_sent()
  end

  test "send mail to 3yo users with less than 75 messages" do
    date = Timex.now() |> Timex.shift(months: -37)
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -3))

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)

    assert user.inactivity_notification_sent_at
    assert_email_sent()

    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -3))
    insert_list(74, :message, user: user, thread: thread, forum: forum)

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)
    assert user.inactivity_notification_sent_at
    assert_email_sent()
  end

  test "don't send mail to 3yo users with 75 or more messages" do
    date = Timex.now() |> Timex.shift(months: -37)
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -3))
    insert_list(75, :message, user: user, thread: thread, forum: forum)
    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)
    refute user.inactivity_notification_sent_at
    refute_email_sent()
  end

  test "send mail to 4yo users with less than 100 messages" do
    date = Timex.now() |> Timex.shift(months: -49)
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -4))

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)

    assert user.inactivity_notification_sent_at
    assert_email_sent()

    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -4))
    insert_list(99, :message, user: user, thread: thread, forum: forum)

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)
    assert user.inactivity_notification_sent_at
    assert_email_sent()
  end

  test "don't send mail to 4yo users with 100 or more messages" do
    date = Timex.now() |> Timex.shift(months: -49)
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    user = insert(:user, last_visit: date, created_at: Timex.now() |> Timex.shift(years: -4))
    insert_list(100, :message, user: user, thread: thread, forum: forum)
    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)
    refute user.inactivity_notification_sent_at
    refute_email_sent()
  end

  test "send mail to users inactive longer than five years" do
    date = Timex.now() |> Timex.shift(years: -5)
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    user = insert(:user, last_visit: date, created_at: date)

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)

    assert user.inactivity_notification_sent_at
    assert_email_sent()

    user = insert(:user, last_visit: date, created_at: date)
    insert_list(100, :message, user: user, thread: thread, forum: forum, created_at: date)

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)
    assert user.inactivity_notification_sent_at
    assert_email_sent()
  end

  test "don't send mail to users active in the last five years" do
    date = Timex.now() |> Timex.shift(years: -5)
    user = insert(:user, last_visit: Timex.now(), created_at: date)

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)

    refute user.inactivity_notification_sent_at
    refute_email_sent()
  end

  test "doesn't fail on users w/o email address" do
    date = Timex.now() |> Timex.shift(years: -5)
    user = insert(:user, last_visit: date, created_at: date, email: nil)

    Cforum.Jobs.SendInactivityNotificationMailJob.perform(nil, nil)
    user = Repo.get!(User, user.user_id)

    refute user.inactivity_notification_sent_at
    refute_email_sent()
  end
end
