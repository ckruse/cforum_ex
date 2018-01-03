defmodule Cforum.Forums.MessagesTest do
  use Cforum.DataCase

  alias Cforum.Forums.Messages
  alias Cforum.Forums.Message
  alias Cforum.Forums.Thread

  setup do
    user = insert(:user)
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum, user: user, tags: [])

    {:ok, user: user, forum: forum, thread: thread, message: message}
  end

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

  test "count_messages_for_user_by_month/2 counts the messages of a user grouped by month", %{user: user, forum: forum} do
    messages = Messages.count_messages_for_user_by_month(user, [forum.forum_id])
    assert length(messages) == 1
    assert [{_, 1}] = messages
  end

  test "count_messages_per_tag_for_user/2 counts the messages per tag of a user"

  test "get_message!/1 returns the message with given id", %{message: message} do
    message1 = Messages.get_message!(message.message_id)
    assert %Message{} = message1
    assert message1.message_id == message.message_id
  end

  test "get_message_from_slug_and_mid!/4 returns the message with the given slug & mid", %{
    user: user,
    forum: forum,
    thread: thread,
    message: message
  } do
    thread_and_message = Messages.get_message_from_slug_and_mid!(forum, user, thread.slug, message.message_id)
    assert {%Thread{}, %Message{} = message1} = thread_and_message
    assert message1.message_id == message.message_id
  end

  test "preview_message/3 generates a %Message{} and a changeset", %{thread: thread, message: message} do
    assert {%Message{}, %Ecto.Changeset{}} = Messages.preview_message(%{}, nil, thread)
    assert {%Message{parent_id: mid}, %Ecto.Changeset{}} = Messages.preview_message(%{}, nil, thread, message)
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
    assert {:ok, %Message{} = message1} = Messages.create_message(params, user, [forum], thread, message)
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

  # TODO test update_message()

  test "delete_message/1 marks the message as deleted", %{message: message} do
    assert {:ok, %Message{}} = Messages.delete_message(message)
    assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message.message_id) end
    assert %Message{} = Messages.get_message!(message.message_id, view_all: true)
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
