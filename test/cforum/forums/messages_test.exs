defmodule Cforum.MessagesTest do
  use Cforum.DataCase

  alias Cforum.Forums.{Messages, Message}
  alias Cforum.Threads
  alias Cforum.Threads.Thread

  setup do
    user = insert(:user)
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum, user: user, tags: [])
    tag = insert(:tag, messages: [message])

    {:ok, user: user, forum: forum, thread: thread, message: message, tag: tag}
  end

  describe "message lists" do
    test "list_messages_for_user/2 returns a list of messages", %{user: user, message: message} do
      messages = Messages.list_messages_for_user(user, [message.forum_id])
      assert length(messages) == 1
      assert [%Message{}] = messages
      assert Enum.map(messages, & &1.message_id) == [message.message_id]
    end

    test "count_messages_for_user/2 counts the messages of a user", %{user: user, message: message} do
      cnt = Messages.count_messages_for_user(user, [message.forum_id])
      assert cnt == 1
    end

    test "list_messages_for_tag/2 returns a list of messages", %{forum: f, tag: t, message: message} do
      messages = Messages.list_messages_for_tag([f], t)

      assert length(messages) == 1
      assert [%Message{}] = messages
      assert Enum.map(messages, & &1.message_id) == [message.message_id]
    end

    test "count_messages_for_tag/2 counts the messages of a tag", %{forum: f, tag: t} do
      cnt = Messages.count_messages_for_tag([f], t)
      assert cnt == 1
    end

    test "list_best_scored_messages_for_user/2 returns a list of best scored messages", %{
      user: user,
      forum: forum,
      thread: thread
    } do
      m1 = insert(:message, thread: thread, forum: forum, user: user, upvotes: 1)
      m2 = insert(:message, thread: thread, forum: forum, user: user, upvotes: 5)
      m3 = insert(:message, thread: thread, forum: forum, user: user, upvotes: 2)

      messages = Messages.list_best_scored_messages_for_user(user, [forum.forum_id], 3)
      assert length(messages) == 3
      assert [%Message{}, %Message{}, %Message{}] = messages
      assert Enum.map(messages, & &1.message_id) == [m2.message_id, m3.message_id, m1.message_id]
    end

    test "list_scored_msgs_for_user_in_perspective/3 returns a list of scored messages", %{message: message, user: user} do
      insert(:vote, user: user, message: message, score: build(:score, message: message, user: user))
      messages = Messages.list_scored_msgs_for_user_in_perspective(user, nil, [message.forum_id])
      assert length(messages) == 1
      assert [%Cforum.Accounts.Score{}] = messages
      assert Enum.map(messages, & &1.message_id) == [message.message_id]
    end

    test "list_scored_msgs_for_user_in_perspective/3 excludes negative scores", %{message: message, user: user} do
      insert(:vote, user: user, message: message, score: build(:score, message: message, user: user, value: -1))
      messages = Messages.list_scored_msgs_for_user_in_perspective(user, nil, [message.forum_id])
      assert messages == []
    end

    test "list_scored_msgs_for_user_in_perspective/3 includes negative scores for own scores", %{
      message: message,
      user: user
    } do
      insert(:vote, user: user, message: message, score: build(:score, message: message, user: user, value: -1))
      messages = Messages.list_scored_msgs_for_user_in_perspective(user, user, [message.forum_id])
      assert length(messages) == 1
      assert [%Cforum.Accounts.Score{}] = messages
      assert Enum.map(messages, & &1.message_id) == [message.message_id]
    end

    test "count_scored_msgs_for_user_in_perspective/3 counts the scored messages of a user", %{
      message: message,
      user: user
    } do
      insert(:vote, user: user, message: message, score: build(:score, message: message, user: user))
      assert Messages.count_scored_msgs_for_user_in_perspective(user, nil, [message.forum_id]) == 1
    end

    test "count_scored_msgs_for_user_in_perspective/3 excludes messages w/ negative score", %{
      message: message,
      user: user
    } do
      insert(:vote, user: user, message: message, score: build(:score, message: message, user: user, value: -1))
      assert Messages.count_scored_msgs_for_user_in_perspective(user, nil, [message.forum_id]) == 0
    end

    test "count_scored_msgs_for_user_in_perspective/3 includes messages w/ negative score for oneself", %{
      message: message,
      user: user
    } do
      insert(:vote, user: user, message: message, score: build(:score, message: message, user: user, value: -1))
      assert Messages.count_scored_msgs_for_user_in_perspective(user, user, [message.forum_id]) == 1
    end

    test "count_messages_for_user_by_month/2 counts the messages of a user grouped by month", %{
      user: user,
      forum: forum
    } do
      messages = Messages.count_messages_for_user_by_month(user, [forum.forum_id])
      assert length(messages) == 1
      assert [{_, 1}] = messages
    end

    test "count_messages_per_tag_for_user/2 counts the messages per tag of a user", %{user: u, forum: f, tag: t} do
      messages = Messages.count_messages_per_tag_for_user(u, [f.forum_id])
      assert length(messages) == 1
      assert [{t_slug, t_name, 1}] = messages
      assert t_slug == t.slug
      assert t_name == t.tag_name
    end
  end

  describe "getting messages" do
    test "get_message!/1 returns the message with given id", %{message: message} do
      message1 = Messages.get_message!(message.message_id)
      assert %Message{} = message1
      assert message1.message_id == message.message_id
    end

    test "get_message!/1 raises an Ecto.NoResultsError when message is marked as deleted", %{message: message} do
      message
      |> Ecto.Changeset.change(deleted: true)
      |> Repo.update!()

      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message.message_id) end
    end

    test "get_message!/1 returns a deleted message when view_all is true", %{message: message} do
      message
      |> Ecto.Changeset.change(deleted: true)
      |> Repo.update!()

      message1 = Messages.get_message!(message.message_id, view_all: true)
      assert %Message{} = message1
      assert message1.message_id == message.message_id
    end

    test "get_message/1 returns the message with given id", %{message: message} do
      message1 = Messages.get_message(message.message_id)
      assert %Message{} = message1
      assert message1.message_id == message.message_id
    end

    test "get_message/1 returns nil when message is marked as deleted", %{message: message} do
      message
      |> Ecto.Changeset.change(deleted: true)
      |> Repo.update!()

      assert Messages.get_message(message.message_id) == nil
    end

    test "get_message/1 returns a deleted message when view_all is true", %{message: message} do
      message
      |> Ecto.Changeset.change(deleted: true)
      |> Repo.update!()

      message1 = Messages.get_message(message.message_id, view_all: true)
      assert %Message{} = message1
      assert message1.message_id == message.message_id
    end

    test "get_message_and_thread!/5 returns a message and a thread", %{thread: t, message: m} do
      assert {thread, message} = Messages.get_message_and_thread!(nil, nil, t.thread_id, m.message_id)
      assert thread.thread_id == t.thread_id
      assert message.message_id == m.message_id
    end

    test "get_message_and_thread!/5 raises Ecto.NoResultsError when message is deleted", %{thread: t, message: m} do
      m
      |> Ecto.Changeset.change(deleted: true)
      |> Repo.update!()

      assert_raise Ecto.NoResultsError, fn ->
        Messages.get_message_and_thread!(nil, nil, t.thread_id, m.message_id)
      end
    end

    test "get_message_and_thread!/5 raises Ecto.NoResultsError when message doesn't exist", %{thread: t} do
      assert_raise Ecto.NoResultsError, fn ->
        Messages.get_message_and_thread!(nil, nil, t.thread_id, -1)
      end
    end

    test "get_message_and_thread!/5 returns a message and a thread when deleted and view_all is true", %{
      thread: t,
      message: m
    } do
      m
      |> Ecto.Changeset.change(deleted: true)
      |> Repo.update!()

      assert {thread, message} = Messages.get_message_and_thread!(nil, nil, t.thread_id, m.message_id, view_all: true)

      assert thread.thread_id == t.thread_id
      assert message.message_id == m.message_id
    end

    test "find_message/2 finds a message", %{thread: t, message: m} do
      thread =
        Threads.get_thread!(t.thread_id)
        |> Threads.build_message_tree("ascending")

      found_message = Messages.find_message(thread, &(&1.message_id == m.message_id))
      assert %Message{} = found_message
      assert found_message.message_id == m.message_id
    end

    test "find_message/2 returns nil when message could not be found", %{thread: t} do
      thread =
        Threads.get_thread!(t.thread_id)
        |> Threads.build_message_tree("ascending")

      assert Messages.find_message(thread, fn _ -> false end) == nil
    end

    test "find_message/2 finds a message in a message list", %{thread: t, message: m} do
      thread =
        Threads.get_thread!(t.thread_id)
        |> Threads.build_message_tree("ascending")

      found_message = Messages.find_message([thread.tree], &(&1.message_id == m.message_id))
      assert %Message{} = found_message
      assert found_message.message_id == m.message_id
    end

    test "find_message/2 finds a message in a deeper level", %{forum: f, thread: t, message: m} do
      message = insert(:message, parent_id: m.message_id, thread: t, forum: f)

      thread =
        Threads.get_thread!(t.thread_id)
        |> Threads.build_message_tree("ascending")

      found_message = Messages.find_message(thread, &(&1.message_id == message.message_id))
      assert %Message{} = found_message
      assert found_message.message_id == message.message_id
    end
  end

  describe "creating messages" do
    test "preview_message/3 generates a %Message{} and a changeset", %{thread: thread, message: message} do
      assert {%Message{}, %Ecto.Changeset{}} = Messages.preview_message(%{}, nil, [], thread)
      assert {%Message{parent_id: mid}, %Ecto.Changeset{}} = Messages.preview_message(%{}, nil, [], thread, message)
      assert mid == message.message_id
    end

    test "create_message/4 with valid data creates a message", %{user: user, thread: thread, forum: forum} do
      params = params_for(:message)
      assert {:ok, %Message{} = message} = Messages.create_message(params, user, [forum], thread)
      assert message.user_id == user.user_id
      assert message.subject == params[:subject]
    end

    test "create_message/5 creates a child message", %{user: user, thread: thread, forum: forum, message: message} do
      params = params_for(:message)

      assert {:ok, %Message{} = message1} =
               Messages.create_message(params, user, [forum], %Thread{thread | tree: message}, message)

      assert message1.user_id == user.user_id
      assert message1.subject == params[:subject]
      assert message1.parent_id == message.message_id
    end

    test "create_message/4 with invalid data returns error changeset", %{user: user, thread: thread, forum: forum} do
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(%{}, user, [forum], thread)
    end

    test "create_message/4 with registered foreign name returns error changeset", %{
      user: user,
      thread: thread,
      forum: forum
    } do
      params = params_for(:message, author: user.username)
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(params, nil, [forum], thread)
    end

    test "change_message/3 returns a message changeset", %{user: user, forum: forum, message: message} do
      assert %Ecto.Changeset{} = Messages.change_message(message, user, [forum])
    end

    test "new_message_changeset/3 returns a message changeset with parent message", %{
      user: user,
      forum: forum,
      message: message
    } do
      changeset = Messages.new_message_changeset(message, user, [forum])
      assert %Ecto.Changeset{} = changeset
      assert Ecto.Changeset.get_field(changeset, :subject) == message.subject
    end

    test "new_message_changeset/3 returns a message changeset", %{user: user, forum: forum} do
      assert %Ecto.Changeset{} = Messages.new_message_changeset(nil, user, [forum])
    end
  end

  describe "creating messages: may user post with name?" do
    test "user may post with name: equal: username and name are equal", %{user: u, forum: f, thread: t} do
      params = params_for(:message, author: u.username)
      assert {:ok, %Message{} = message} = Messages.create_message(params, u, [f], t)
      assert message.user_id == u.user_id
      assert message.subject == params[:subject]
    end

    test "user may post with name: equal: name contains blanks", %{user: u, forum: f, thread: t} do
      params = params_for(:message, author: "  #{u.username}    ")
      assert {:ok, %Message{} = message} = Messages.create_message(params, u, [f], t)
      assert message.user_id == u.user_id
      assert message.subject == params[:subject]
      assert message.author == u.username
    end

    test "user may post with name: equal: name differs in case", %{user: u, forum: f, thread: t} do
      params = params_for(:message, author: String.upcase(u.username))
      assert {:ok, %Message{} = message} = Messages.create_message(params, u, [f], t)
      assert message.user_id == u.user_id
      assert message.subject == params[:subject]
    end

    test "user may not post with name: user exists", %{user: u, forum: f, thread: t} do
      params = params_for(:message, author: u.username)
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(params, nil, [f], t)
    end

    test "user may not post with name: user exists and own username is different", %{user: u, forum: f, thread: t} do
      u1 = insert(:user)
      params = params_for(:message, author: u1.username)
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(params, u, [f], t)
    end

    test "user may not post with name: user exists with blanks", %{user: u, forum: f, thread: t} do
      params = params_for(:message, author: "    #{u.username}  ")
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(params, nil, [f], t)
    end

    test "user may not post with name: user exists with differing case", %{user: u, forum: f, thread: t} do
      params = params_for(:message, author: String.upcase(u.username))
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(params, nil, [f], t)
    end
  end

  # TODO test update_message()

  test "delete_message/1 marks the message as deleted", %{message: message} do
    thread =
      Threads.get_thread!(message.thread_id)
      |> Threads.build_message_tree("ascending")

    msg = Messages.get_message_from_mid!(thread, message.message_id)

    assert {:ok, %Message{}} = Messages.delete_message(nil, msg)
    assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message.message_id) end
    assert %Message{} = Messages.get_message!(message.message_id, view_all: true)
  end

  describe "read/unread messages" do
    alias Cforum.Messages.{ReadMessages, ReadMessage}

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

    test "cound_unread_messages/2 counts the number of unread messages for a user", %{message: m, user: u} do
      assert ReadMessages.count_unread_messages(u) == {1, 1}
      ReadMessages.mark_messages_read(u, m)
      assert ReadMessages.count_unread_messages(u) == {0, 0}
    end

    test "count_unread_messages/2 returns 0 w/o a user" do
      assert ReadMessages.count_unread_messages(nil) == {0, 0}
    end
  end

  describe "subscriptions" do
    alias Cforum.Messages.Subscription

    test "subscribe_message/2 subscribes a message for a user", %{user: u, message: m} do
      assert {:ok, %Subscription{}} = Messages.subscribe_message(u, m)
    end

    test "unsubscribe_message/2 unsubscribes a message for a user", %{user: u, message: m} do
      assert {:ok, %Subscription{}} = Messages.subscribe_message(u, m)
      assert {:ok, %Subscription{}} = Messages.unsubscribe_message(u, m)
    end

    test "unsubscribe_message/2 returns nil when a message isn't subscribed", %{user: u, message: m} do
      assert nil == Messages.unsubscribe_message(u, m)
    end

    test "list_subscriptions/2 lists subscribed messages", %{user: u, message: m} do
      assert {:ok, %Subscription{}} = Messages.subscribe_message(u, m)
      assert [%Message{}] = Messages.list_subscriptions(u)
    end

    test "count_subscriptions/1 counts subscribed messages", %{user: u, message: m} do
      assert Messages.count_subscriptions(u) == 0
      assert {:ok, %Subscription{}} = Messages.subscribe_message(u, m)
      assert Messages.count_subscriptions(u) == 1
    end

    test "parent_subscribed?/2 returns false if there is no parent message", %{message: m, thread: t} do
      assert Messages.parent_subscribed?(t, m) == false
    end

    test "parent_subscribed?/2 returns true if the parent message is subscribed", %{
      message: m,
      thread: t,
      forum: f,
      user: u
    } do
      message = insert(:message, parent_id: m.message_id, thread: t, forum: f)
      assert {:ok, %Subscription{}} = Messages.subscribe_message(u, m)

      thread =
        Threads.get_thread!(t.thread_id)
        |> Threads.apply_user_infos(u)
        |> Threads.build_message_tree("ascending")

      assert Messages.parent_subscribed?(thread, message) == true
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

      assert Messages.parent_subscribed?(thread, message) == false
    end
  end

  describe "interesting message" do
    alias Cforum.Messages.InterestingMessage

    test "mark_message_interesting/2 marks a message as interesting for a user", %{user: u, message: m} do
      assert {:ok, %InterestingMessage{}} = Messages.mark_message_interesting(u, m)
    end

    test "mark_message_boring/2 marks a message as boring for a user", %{user: u, message: m} do
      assert {:ok, %InterestingMessage{}} = Messages.mark_message_interesting(u, m)
      assert {:ok, %InterestingMessage{}} = Messages.mark_message_boring(u, m)
    end

    test "mark_message_boring/2 returns nil when a message isn't marked interesting", %{user: u, message: m} do
      assert nil == Messages.mark_message_boring(u, m)
    end

    test "list_interesting_messages/1 lists interesting messages", %{user: u, message: m} do
      assert {:ok, %InterestingMessage{}} = Messages.mark_message_interesting(u, m)
      assert [%Message{}] = Messages.list_interesting_messages(u)
    end

    test "count_interesting_messages/1 counts messages marked as interesting", %{user: u, message: m} do
      assert Messages.count_interesting_messages(u) == 0
      assert {:ok, %InterestingMessage{}} = Messages.mark_message_interesting(u, m)
      assert Messages.count_interesting_messages(u) == 1
    end
  end

  describe "parent message" do
    test "parent_message/2 returns nil when there is no parent message", %{message: m, thread: t} do
      assert Messages.parent_message(t, m) == nil
    end

    test "parent_message/2 returns the parent message", %{thread: t, message: m, forum: f} do
      message = insert(:message, parent_id: m.message_id, thread: t, forum: f)

      thread =
        Threads.get_thread!(t.thread_id)
        |> Threads.build_message_tree("ascending")

      found_message = Messages.parent_message(thread, message)
      assert %Message{} = found_message
      assert found_message.message_id == m.message_id
    end
  end

  describe "scoring" do
    test "score_up_message/1 scores a message up", %{message: m} do
      assert {1, _} = Messages.score_up_message(m)
      message = Messages.get_message!(m.message_id)
      assert message.upvotes == 1
    end

    test "score_down_message/1 scores a message down", %{message: m} do
      assert {1, _} = Messages.score_down_message(m)
      message = Messages.get_message!(m.message_id)
      assert message.downvotes == 1
    end
  end

  describe "accepting" do
    test "accept_message/3 accepts a message", %{message: m, user: u} do
      assert {:ok, _} = Messages.accept_message(m, u, 15)
    end

    test "accept_message/3 accepts a message w/o author user", %{message: m, thread: t, forum: f, user: u} do
      m1 = insert(:message, parent_id: m.message_id, thread: t, forum: f)
      assert {:ok, _} = Messages.accept_message(m1, u, 15)
    end

    test "accept_message/3 credits score to the author", %{message: m, user: u} do
      assert {:ok, _} = Messages.accept_message(m, u, 15)
      user = Cforum.Accounts.Users.get_user!(m.user_id)
      assert user.score == 15
    end

    test "accept_message/3 doesn't accept an accepted message", %{message: m, user: u} do
      assert {:ok, _} = Messages.accept_message(m, u, 15)
      m = Messages.get_message!(m.message_id)
      assert Messages.accept_message(m, u, 15) == nil
    end

    test "accept_message/3 doesn't credit score to the author more than once", %{message: m, user: u} do
      Messages.accept_message(m, u, 15)
      Messages.accept_message(m, u, 15)
      user = Cforum.Accounts.Users.get_user!(m.user_id)
      assert user.score == 15
    end

    test "unnaccept_message/3 unaccepts a message", %{message: m, user: u} do
      Messages.accept_message(m, u, 15)
      m = Messages.get_message!(m.message_id)
      assert {:ok, _} = Messages.unaccept_message(m, u)
      m = Messages.get_message!(m.message_id)
      assert Map.has_key?(m.flags, "accepted") == false
    end

    test "unnaccept_message/3 doesn't fail unaccepting a not accepted message", %{message: m, user: u} do
      assert {:ok, _} = Messages.unaccept_message(m, u)
      m = Messages.get_message!(m.message_id)
      assert Map.has_key?(m.flags, "accepted") == false
    end

    test "unnaccept_message/3 unaccepts a message w/o author", %{message: m, thread: t, forum: f, user: u} do
      m1 = insert(:message, parent_id: m.message_id, thread: t, forum: f)
      Messages.accept_message(m1, u, 15)

      m1 = Messages.get_message!(m1.message_id)
      assert {:ok, _} = Messages.unaccept_message(m1, u)

      m1 = Messages.get_message!(m1.message_id)
      assert Map.has_key?(m1.flags, "accepted") == false
    end

    test "unnaccept_message/3 removes user scores", %{message: m, user: u} do
      Messages.accept_message(m, u, 15)
      user = Cforum.Accounts.Users.get_user!(u.user_id)
      assert user.score == 15

      assert {:ok, _} = Messages.unaccept_message(m, u)
      user = Cforum.Accounts.Users.get_user!(u.user_id)
      assert user.score == 0
    end
  end

  describe "flag messages" do
    setup %{message: m, thread: t, forum: f} do
      m1 = insert(:message, parent_id: m.message_id, thread: t, forum: f)
      {thread, message} = Messages.get_message_and_thread!(nil, nil, t.thread_id, m.message_id)

      {:ok, message1: m1, message: message, thread: thread}
    end

    test "it flags a message and its children", %{message: m} do
      thread =
        Threads.get_thread!(m.thread_id)
        |> Threads.build_message_tree("ascending")

      message = Messages.get_message_from_mid!(thread, m.message_id)
      assert {:ok, %Message{}} = Messages.flag_message_subtree(message, "foo", "bar")

      thread =
        Threads.get_thread!(m.thread_id)
        |> Threads.build_message_tree("ascending")

      assert thread.tree.flags["foo"] == "bar"
      assert List.first(thread.tree.messages).flags["foo"] == "bar"
    end

    test "it flags a message and its children as no-answer", %{user: u, message: m} do
      thread =
        Threads.get_thread!(m.thread_id)
        |> Threads.build_message_tree("ascending")

      message = Messages.get_message_from_mid!(thread, m.message_id)
      assert {:ok, %Message{}} = Messages.flag_no_answer(u, message, "no-answer")

      thread =
        Threads.get_thread!(m.thread_id)
        |> Threads.build_message_tree("ascending")

      assert thread.tree.flags["no-answer"] == "yes"
      assert List.first(thread.tree.messages).flags["no-answer"] == "yes"
    end
  end
end
