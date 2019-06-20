defmodule Cforum.Messages.MessagesTagsTest do
  use Cforum.DataCase

  alias Cforum.Messages.Message
  alias Cforum.Messages.MessagesTags

  setup do
    user = insert(:user)
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum, user: user, tags: [])
    tag = insert(:tag, messages: [message])

    {:ok, user: user, forum: forum, thread: thread, message: message, tag: tag}
  end

  test "list_messages_for_tag/2 returns a list of messages", %{forum: f, tag: t, message: message} do
    messages = MessagesTags.list_messages_for_tag([f], t)

    assert length(messages) == 1
    assert [%Message{}] = messages
    assert Enum.map(messages, & &1.message_id) == [message.message_id]
  end

  test "count_messages_for_tag/2 counts the messages of a tag", %{forum: f, tag: t} do
    cnt = MessagesTags.count_messages_for_tag([f], t)
    assert cnt == 1
  end
end
