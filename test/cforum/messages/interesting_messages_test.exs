defmodule Cforum.Messages.InterestingMessagesTest do
  use Cforum.DataCase

  alias Cforum.Messages.InterestingMessages
  alias Cforum.Messages.InterestingMessage
  alias Cforum.Messages.Message

  setup do
    user = insert(:user)
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum, user: user, tags: [])
    tag = insert(:tag, messages: [message])

    {:ok, user: user, forum: forum, thread: thread, message: message, tag: tag}
  end

  test "mark_message_interesting/2 marks a message as interesting for a user", %{user: u, message: m} do
    assert {:ok, %InterestingMessage{}} = InterestingMessages.mark_message_interesting(u, m)
  end

  test "mark_message_boring/2 marks a message as boring for a user", %{user: u, message: m} do
    assert {:ok, %InterestingMessage{}} = InterestingMessages.mark_message_interesting(u, m)
    assert {:ok, %InterestingMessage{}} = InterestingMessages.mark_message_boring(u, m)
  end

  test "mark_message_boring/2 returns nil when a message isn't marked interesting", %{user: u, message: m} do
    assert nil == InterestingMessages.mark_message_boring(u, m)
  end

  test "list_interesting_messages/1 lists interesting messages", %{user: u, message: m} do
    assert {:ok, %InterestingMessage{}} = InterestingMessages.mark_message_interesting(u, m)
    assert [%Message{}] = InterestingMessages.list_interesting_messages(u)
  end

  test "count_interesting_messages/1 counts messages marked as interesting", %{user: u, message: m} do
    assert InterestingMessages.count_interesting_messages(u) == 0
    assert {:ok, %InterestingMessage{}} = InterestingMessages.mark_message_interesting(u, m)
    assert InterestingMessages.count_interesting_messages(u) == 1
  end
end
