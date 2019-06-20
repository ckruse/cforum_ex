defmodule Cforum.Messages.MessagesUsersTest do
  use Cforum.DataCase

  alias Cforum.Messages.Message
  alias Cforum.Messages.MessagesUsers

  setup do
    user = insert(:user)
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum, user: user, tags: [])
    tag = insert(:tag, messages: [message])

    {:ok, user: user, forum: forum, thread: thread, message: message, tag: tag}
  end

  test "list_messages_for_user/2 returns a list of messages", %{user: user, message: message} do
    messages = MessagesUsers.list_messages_for_user(user, [message.forum_id])
    assert length(messages) == 1
    assert [%Message{}] = messages
    assert Enum.map(messages, & &1.message_id) == [message.message_id]
  end

  test "list_best_scored_messages_for_user/2 returns a list of best scored messages", %{
    user: user,
    forum: forum,
    thread: thread
  } do
    m1 = insert(:message, thread: thread, forum: forum, user: user, upvotes: 1)
    m2 = insert(:message, thread: thread, forum: forum, user: user, upvotes: 5)
    m3 = insert(:message, thread: thread, forum: forum, user: user, upvotes: 2)

    messages = MessagesUsers.list_best_scored_messages_for_user(user, [forum.forum_id], 3)
    assert length(messages) == 3
    assert [%Message{}, %Message{}, %Message{}] = messages
    assert Enum.map(messages, & &1.message_id) == [m2.message_id, m3.message_id, m1.message_id]
  end

  test "list_scored_msgs_for_user_in_perspective/3 returns a list of scored messages", %{message: message, user: user} do
    insert(:vote, user: user, message: message, score: build(:score, message: message, user: user))
    messages = MessagesUsers.list_scored_msgs_for_user_in_perspective(user, nil, [message.forum_id])
    assert length(messages) == 1
    assert [%Cforum.Accounts.Score{}] = messages
    assert Enum.map(messages, & &1.message_id) == [message.message_id]
  end

  test "list_scored_msgs_for_user_in_perspective/3 excludes negative scores", %{message: message, user: user} do
    insert(:vote, user: user, message: message, score: build(:score, message: message, user: user, value: -1))
    messages = MessagesUsers.list_scored_msgs_for_user_in_perspective(user, nil, [message.forum_id])
    assert messages == []
  end

  test "list_scored_msgs_for_user_in_perspective/3 includes negative scores for own scores", %{
    message: message,
    user: user
  } do
    insert(:vote, user: user, message: message, score: build(:score, message: message, user: user, value: -1))
    messages = MessagesUsers.list_scored_msgs_for_user_in_perspective(user, user, [message.forum_id])
    assert length(messages) == 1
    assert [%Cforum.Accounts.Score{}] = messages
    assert Enum.map(messages, & &1.message_id) == [message.message_id]
  end

  test "count_scored_msgs_for_user_in_perspective/3 counts the scored messages of a user", %{
    message: message,
    user: user
  } do
    insert(:vote, user: user, message: message, score: build(:score, message: message, user: user))
    assert MessagesUsers.count_scored_msgs_for_user_in_perspective(user, nil, [message.forum_id]) == 1
  end

  test "count_scored_msgs_for_user_in_perspective/3 excludes messages w/ negative score", %{
    message: message,
    user: user
  } do
    insert(:vote, user: user, message: message, score: build(:score, message: message, user: user, value: -1))
    assert MessagesUsers.count_scored_msgs_for_user_in_perspective(user, nil, [message.forum_id]) == 0
  end

  test "count_scored_msgs_for_user_in_perspective/3 includes messages w/ negative score for oneself", %{
    message: message,
    user: user
  } do
    insert(:vote, user: user, message: message, score: build(:score, message: message, user: user, value: -1))
    assert MessagesUsers.count_scored_msgs_for_user_in_perspective(user, user, [message.forum_id]) == 1
  end

  test "count_messages_for_user_by_month/2 counts the messages of a user grouped by month", %{
    user: user,
    forum: forum
  } do
    messages = MessagesUsers.count_messages_for_user_by_month(user, [forum.forum_id])
    assert length(messages) == 1
    assert [{_, 1}] = messages
  end

  test "count_messages_per_tag_for_user/2 counts the messages per tag of a user", %{user: u, forum: f, tag: t} do
    messages = MessagesUsers.count_messages_per_tag_for_user(u, [f.forum_id])
    assert length(messages) == 1
    assert [{t_slug, t_name, 1}] = messages
    assert t_slug == t.slug
    assert t_name == t.tag_name
  end

  test "count_messages_for_user/2 counts the messages of a user", %{user: user, message: message} do
    cnt = MessagesUsers.count_messages_for_user(user, [message.forum_id])
    assert cnt == 1
  end
end
