defmodule Cforum.Messages.MessageHelpersTest do
  use Cforum.DataCase

  alias Cforum.Messages.MessageHelpers
  alias Cforum.Messages.Message
  alias Cforum.Threads

  setup do
    user = insert(:user)
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum, user: user, tags: [])
    tag = insert(:tag, messages: [message])

    {:ok, user: user, forum: forum, thread: thread, message: message, tag: tag}
  end

  test "find_message/2 finds a message", %{thread: t, message: m} do
    thread =
      Threads.get_thread!(t.thread_id)
      |> Threads.build_message_tree("ascending")

    found_message = MessageHelpers.find_message(thread, &(&1.message_id == m.message_id))
    assert %Message{} = found_message
    assert found_message.message_id == m.message_id
  end

  test "find_message/2 returns nil when message could not be found", %{thread: t} do
    thread =
      Threads.get_thread!(t.thread_id)
      |> Threads.build_message_tree("ascending")

    assert MessageHelpers.find_message(thread, fn _ -> false end) == nil
  end

  test "find_message/2 finds a message in a message list", %{thread: t, message: m} do
    thread =
      Threads.get_thread!(t.thread_id)
      |> Threads.build_message_tree("ascending")

    found_message = MessageHelpers.find_message([thread.tree], &(&1.message_id == m.message_id))
    assert %Message{} = found_message
    assert found_message.message_id == m.message_id
  end

  test "find_message/2 finds a message in a deeper level", %{forum: f, thread: t, message: m} do
    message = insert(:message, parent_id: m.message_id, thread: t, forum: f)

    thread =
      Threads.get_thread!(t.thread_id)
      |> Threads.build_message_tree("ascending")

    found_message = MessageHelpers.find_message(thread, &(&1.message_id == message.message_id))
    assert %Message{} = found_message
    assert found_message.message_id == message.message_id
  end

  test "parent_message/2 returns nil when there is no parent message", %{message: m, thread: t} do
    assert MessageHelpers.parent_message(t, m) == nil
  end

  test "parent_message/2 returns the parent message", %{thread: t, message: m, forum: f} do
    message = insert(:message, parent_id: m.message_id, thread: t, forum: f)

    thread =
      Threads.get_thread!(t.thread_id)
      |> Threads.build_message_tree("ascending")

    found_message = MessageHelpers.parent_message(thread, message)
    assert %Message{} = found_message
    assert found_message.message_id == m.message_id
  end
end
