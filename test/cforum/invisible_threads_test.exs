defmodule Cforum.InvisibleThreadsTest do
  use Cforum.DataCase

  alias Cforum.InvisibleThreads
  alias Cforum.InvisibleThreads.InvisibleThread
  alias Cforum.Threads.Thread
  alias Cforum.Messages

  setup do
    user = insert(:user)
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum, user: user)

    {:ok, user: user, forum: forum, thread: thread, message: message}
  end

  describe "list_invisible_threads" do
    test "lists invisible threads", %{user: user, thread: thread, forum: forum} do
      InvisibleThreads.hide_thread(user, thread)
      assert {1, [%Thread{}]} = InvisibleThreads.list_invisible_threads(user, [forum])
    end

    test "lists threads w/ only one deleted message w/ a reason", %{
      user: user,
      forum: forum,
      message: message,
      thread: thread
    } do
      Messages.delete_message(user, %{message | messages: []}, "spam")
      InvisibleThreads.hide_thread(user, thread)
      assert {1, [%Thread{}]} = InvisibleThreads.list_invisible_threads(user, [forum])
    end
  end

  describe "hide_thread" do
    test "hides a thread", %{thread: thread, user: user} do
      assert {:ok, %InvisibleThread{}} = InvisibleThreads.hide_thread(user, thread)
    end
  end

  describe "unhide_thread" do
    test "unhides a thread", %{thread: thread, user: user} do
      InvisibleThreads.hide_thread(user, thread)
      assert {:ok, %InvisibleThread{}} = InvisibleThreads.unhide_thread(user, thread)
    end
  end
end
