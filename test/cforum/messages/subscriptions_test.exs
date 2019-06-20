defmodule Cforum.Messages.SubscriptionsTest do
  use Cforum.DataCase

  alias Cforum.Messages.Subscriptions
  alias Cforum.Messages.Message
  alias Cforum.Threads
  alias Cforum.Messages.Subscription

  setup do
    user = insert(:user)
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum, user: user, tags: [])
    tag = insert(:tag, messages: [message])

    {:ok, user: user, forum: forum, thread: thread, message: message, tag: tag}
  end

  test "subscribe_message/2 subscribes a message for a user", %{user: u, message: m} do
    assert {:ok, %Subscription{}} = Subscriptions.subscribe_message(u, m)
  end

  test "unsubscribe_message/2 unsubscribes a message for a user", %{user: u, message: m} do
    assert {:ok, %Subscription{}} = Subscriptions.subscribe_message(u, m)
    assert {:ok, %Subscription{}} = Subscriptions.unsubscribe_message(u, m)
  end

  test "unsubscribe_message/2 returns nil when a message isn't subscribed", %{user: u, message: m} do
    assert nil == Subscriptions.unsubscribe_message(u, m)
  end

  test "list_subscriptions/2 lists subscribed messages", %{user: u, message: m} do
    assert {:ok, %Subscription{}} = Subscriptions.subscribe_message(u, m)
    assert [%Message{}] = Subscriptions.list_subscriptions(u)
  end

  test "count_subscriptions/1 counts subscribed messages", %{user: u, message: m} do
    assert Subscriptions.count_subscriptions(u) == 0
    assert {:ok, %Subscription{}} = Subscriptions.subscribe_message(u, m)
    assert Subscriptions.count_subscriptions(u) == 1
  end

  test "parent_subscribed?/2 returns false if there is no parent message", %{message: m, thread: t} do
    assert Subscriptions.parent_subscribed?(t, m) == false
  end

  test "parent_subscribed?/2 returns true if the parent message is subscribed", %{
    message: m,
    thread: t,
    forum: f,
    user: u
  } do
    message = insert(:message, parent_id: m.message_id, thread: t, forum: f)
    assert {:ok, %Subscription{}} = Subscriptions.subscribe_message(u, m)

    thread =
      Threads.get_thread!(t.thread_id)
      |> Threads.apply_user_infos(u)
      |> Threads.build_message_tree("ascending")

    assert Subscriptions.parent_subscribed?(thread, message) == true
  end

  test "parent_subscribed?/2 returns false if the parent message isn't subscribed", %{
    message: m,
    thread: t,
    forum: f,
    user: u
  } do
    message = insert(:message, parent_id: m.message_id, thread: t, forum: f)

    thread =
      Threads.get_thread!(t.thread_id)
      |> Threads.apply_user_infos(u)
      |> Threads.build_message_tree("ascending")

    assert Subscriptions.parent_subscribed?(thread, message) == false
  end
end
