defmodule Cforum.ReadMessagesTest do
  use Cforum.DataCase

  alias Cforum.ReadMessages
  alias Cforum.ReadMessages.ReadMessage

  setup do
    user = insert(:user)
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum, user: user, tags: [])
    tag = insert(:tag, messages: [message])

    {:ok, user: user, forum: forum, thread: thread, message: message, tag: tag}
  end

  describe "mark messages read" do
    test "mark_messages_read/2 marks messages read for a user", %{message: m, user: u, thread: t, forum: f} do
      m1 = insert(:message, thread: t, forum: f)
      assert [%ReadMessage{}, %ReadMessage{}] = ReadMessages.mark_messages_read(u, [m, m1])
    end

    test "mark_messages_read/2 marks a message read for a user", %{message: m, user: u} do
      assert [%ReadMessage{}] = ReadMessages.mark_messages_read(u, m)
    end

    test "mark_messages_read/2 returns nil when called w/o a user", %{message: m} do
      assert ReadMessages.mark_messages_read(nil, m) == nil
    end
  end

  describe "cound unread messages" do
    test "cound_unread_messages/2 counts the number of unread messages for a user", %{message: m, user: u, forum: f} do
      assert ReadMessages.count_unread_messages(u, [f]) == {1, 1}
      ReadMessages.mark_messages_read(u, m)
      assert ReadMessages.count_unread_messages(u, [f]) == {0, 0}
    end

    test "count_unread_messages/2 returns 0 w/o a user", %{forum: f} do
      assert ReadMessages.count_unread_messages(nil, [f]) == {0, 0}
    end
  end
end
