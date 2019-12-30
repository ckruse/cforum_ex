defmodule Cforum.PrivMessagesTest do
  use Cforum.DataCase

  alias Cforum.PrivMessages
  alias Cforum.PrivMessages.PrivMessage

  test "list_priv_messages/1 returns all priv_messages of one owner" do
    priv_message = insert(:priv_message)
    pm1 = insert(:priv_message, owner: priv_message.owner)
    insert(:priv_message)

    priv_messages = PrivMessages.list_priv_messages(priv_message.owner)
    assert length(priv_messages) == 2
    assert [%PrivMessage{}, %PrivMessage{}] = priv_messages
    assert Enum.map(priv_messages, & &1.priv_message_id) == [pm1.priv_message_id, priv_message.priv_message_id]
  end

  test "count_priv_messages/1 counts all priv_messages of one user" do
    priv_message = insert(:priv_message)
    insert(:priv_message, owner: priv_message.owner)
    insert(:priv_message)

    assert PrivMessages.count_priv_messages(priv_message.owner) == 2
  end

  test "count_priv_messages/2 counts all unread priv_messages of one user" do
    priv_message = insert(:priv_message, is_read: false)
    insert(:priv_message, owner: priv_message.owner, is_read: true)
    insert(:priv_message, is_read: false)

    assert PrivMessages.count_priv_messages(priv_message.owner, true) == 1
  end

  test "list_newest_priv_messages_of_each_thread/1 returns the newest priv_message of each thread" do
    user = insert(:user)
    insert_pair(:priv_message, thread_id: 1, owner: user)
    insert_pair(:priv_message, thread_id: 2, owner: user)

    priv_messages = PrivMessages.list_newest_priv_messages_of_each_thread(user)
    assert length(priv_messages) == 2
    assert [%PrivMessage{thread_id: 2}, %PrivMessage{thread_id: 1}] = priv_messages
  end

  test "list_newest_priv_messages_of_each_thread/1 returns the newest priv_message of each thread only for desired user" do
    user = insert(:user)
    insert_pair(:priv_message, thread_id: 1, owner: user)
    insert_pair(:priv_message, thread_id: 2, owner: user)

    insert_pair(:priv_message, thread_id: 1)
    insert_pair(:priv_message, thread_id: 3)

    priv_messages = PrivMessages.list_newest_priv_messages_of_each_thread(user)
    assert length(priv_messages) == 2
    assert [%PrivMessage{thread_id: 2, owner_id: oid1}, %PrivMessage{thread_id: 1, owner_id: oid2}] = priv_messages
    assert oid1 == user.user_id
    assert oid2 == user.user_id
  end

  test "count_newest_priv_messages_of_each_thread/1 counts the newest priv_message of each thread" do
    user = insert(:user)
    insert_pair(:priv_message, thread_id: 1, owner: user)
    insert_pair(:priv_message, thread_id: 2, owner: user)

    assert PrivMessages.count_newest_priv_messages_of_each_thread(user) == 2
  end

  test "count_newest_priv_messages_of_each_thread/1 counts the newest priv_message of each thread for desired user only" do
    user = insert(:user)
    insert_pair(:priv_message, thread_id: 1, owner: user)
    insert_pair(:priv_message, thread_id: 2, owner: user)
    insert_pair(:priv_message, thread_id: 3)

    assert PrivMessages.count_newest_priv_messages_of_each_thread(user) == 2
  end

  test "get_priv_message!/1 returns the priv_message with given id" do
    priv_message = insert(:priv_message)
    priv_message1 = PrivMessages.get_priv_message!(priv_message.owner, priv_message.priv_message_id)
    assert %PrivMessage{} = priv_message1
    assert priv_message1.priv_message_id == priv_message.priv_message_id
  end

  test "get_priv_message_thread!/2 returns the whole thread of messages" do
    user = insert(:user)
    priv_messages = insert_list(3, :priv_message, thread_id: 1, owner: user)

    pms = PrivMessages.get_priv_message_thread!(user, 1)
    assert length(pms) == 3
    assert [%PrivMessage{thread_id: 1}, %PrivMessage{thread_id: 1}, %PrivMessage{thread_id: 1}] = pms
    assert Enum.map(pms, & &1.priv_message_id) == Enum.map(Enum.reverse(priv_messages), & &1.priv_message_id)
  end

  test "get_priv_message_thread!/2 only returns the user's messages" do
    user = insert(:user)
    user2 = insert(:user)
    priv_messages = insert_list(3, :priv_message, thread_id: 1, owner: user)
    insert_list(3, :priv_message, thread_id: 1, owner: user2)

    pms = PrivMessages.get_priv_message_thread!(user, 1)
    assert length(pms) == 3
    assert [%PrivMessage{thread_id: 1}, %PrivMessage{thread_id: 1}, %PrivMessage{thread_id: 1}] = pms
    assert Enum.map(pms, & &1.priv_message_id) == Enum.map(Enum.reverse(priv_messages), & &1.priv_message_id)
  end

  test "create_priv_message/1 with valid data creates a priv_message" do
    user = insert(:user)
    params = params_for(:priv_message, recipient: user)

    assert {:ok, %PrivMessage{} = priv_message} = PrivMessages.create_priv_message(user, params)
    assert priv_message.owner_id == user.user_id
    assert priv_message.subject == params[:subject]
  end

  test "create_priv_message/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = PrivMessages.create_priv_message(nil)
  end

  test "delete_priv_message/1 deletes the priv_message" do
    priv_message = insert(:priv_message)
    assert {:ok, %PrivMessage{}} = PrivMessages.delete_priv_message(priv_message)

    assert_raise Ecto.NoResultsError, fn ->
      PrivMessages.get_priv_message!(priv_message.owner, priv_message.priv_message_id)
    end
  end

  test "change_priv_message/1 returns a priv_message changeset" do
    priv_message = insert(:priv_message)
    assert %Ecto.Changeset{} = PrivMessages.change_priv_message(priv_message)
  end

  test "mark_priv_message/2 marks a message unread" do
    pm = insert(:priv_message, is_read: true)
    assert {:ok, pm} = PrivMessages.mark_priv_message(pm, :unread)
    assert pm.is_read == false
  end

  test "mark_priv_message/2 marks a message read" do
    pm = insert(:priv_message, is_read: false)
    assert {:ok, pm} = PrivMessages.mark_priv_message(pm, :read)
    assert pm.is_read == true
  end

  test "partner_name/1 returns the sender name when owner == recipient" do
    [sender, recipient] = insert_pair(:user)
    pm = insert(:priv_message, sender: sender, recipient: recipient, owner: recipient)
    assert PrivMessages.partner_name(pm) == pm.sender_name
  end

  test "partner_name/1 returns the recipient name when owner != recipient" do
    [sender, recipient] = insert_pair(:user)
    pm = insert(:priv_message, sender: sender, recipient: recipient, owner: sender)
    assert PrivMessages.partner_name(pm) == pm.recipient_name
  end

  test "partner_id/1 returns the sender id when owner == recipient" do
    [sender, recipient] = insert_pair(:user)
    pm = insert(:priv_message, sender: sender, recipient: recipient, owner: recipient)
    assert PrivMessages.partner_id(pm) == pm.sender_id
  end

  test "partner_id/1 returns the recipient id when owner != recipient" do
    [sender, recipient] = insert_pair(:user)
    pm = insert(:priv_message, sender: sender, recipient: recipient, owner: sender)
    assert PrivMessages.partner_id(pm) == pm.recipient_id
  end

  test "partner/1 returns the sender when owner == recipient" do
    [sender, recipient] = insert_pair(:user)
    pm = insert(:priv_message, sender: sender, recipient: recipient, owner: recipient)
    assert PrivMessages.partner(pm) == pm.sender
  end

  test "partner/1 returns the recipient when owner != recipient" do
    [sender, recipient] = insert_pair(:user)
    pm = insert(:priv_message, sender: sender, recipient: recipient, owner: sender)
    assert PrivMessages.partner(pm) == pm.recipient
  end

  test "notify_user/1 sends a notification mail to the owner when configured" do
    user = insert(:user)
    insert(:setting, options: %{"notify_on_new_mail" => "email"}, user: user)
    pm = insert(:priv_message, recipient: user)
    assert PrivMessages.notify_user(pm) == true

    assert_enqueued(
      worker: Cforum.Jobs.NotificationMailerJob,
      args: %{"user_id" => user.user_id, "priv_message_id" => pm.priv_message_id, "type" => "priv_message"}
    )
  end

  test "notify_user/1 doesn't send a notification mail to the owner when configured" do
    user = insert(:user)
    pm = insert(:priv_message, recipient: user)
    assert PrivMessages.notify_user(pm) == false

    refute_enqueued(
      worker: Cforum.Jobs.NotificationMailerJob,
      args: %{"user_id" => user.user_id, "priv_message_id" => pm.priv_message_id, "type" => "priv_message"}
    )
  end
end
