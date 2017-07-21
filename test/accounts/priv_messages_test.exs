defmodule Cforum.Accounts.PrivMessagesTest do
  use Cforum.DataCase

  alias Cforum.Accounts.PrivMessages
  alias Cforum.Accounts.PrivMessage

  test "list_priv_messages/0 returns all priv_messages" do
    priv_message = insert(:priv_message)
    priv_messages = PrivMessages.list_priv_messages()
    assert length(priv_messages) == 1
    assert [%PrivMessage{}] = priv_messages
    assert Enum.map(priv_messages, &(&1.priv_message_id)) == [priv_message.priv_message_id]
  end

  test "get_priv_message!/1 returns the priv_message with given id" do
    priv_message = insert(:priv_message)
    priv_message1 = PrivMessages.get_priv_message!(priv_message.priv_message_id)
    assert %PrivMessage{} = priv_message1
    assert priv_message1.priv_message_id == priv_message.priv_message_id
  end

  test "create_priv_message/1 with valid data creates a priv_message" do
    user = insert(:user)
    params = params_for(:priv_message, owner_id: user.user_id)
    assert {:ok, %PrivMessage{} = priv_message} = PrivMessages.create_priv_message(params)
    assert priv_message.owner_id == params[:owner_id]
    assert priv_message.subject == params[:subject]
  end

  test "create_priv_message/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = PrivMessages.create_priv_message(%{})
  end

  test "update_priv_message/2 with valid data updates the priv_message" do
    priv_message = insert(:priv_message)
    assert {:ok, priv_message1} = PrivMessages.update_priv_message(priv_message, %{subject: "Foo"})
    assert %PrivMessage{} = priv_message1
    assert priv_message1.subject == "Foo"
  end

  test "update_priv_message/2 with invalid data returns error changeset" do
    priv_message = insert(:priv_message)
    assert {:error, %Ecto.Changeset{}} = PrivMessages.update_priv_message(priv_message, %{owner_id: nil})
    priv_message1 = PrivMessages.get_priv_message!(priv_message.priv_message_id)
    assert %PrivMessage{} = priv_message1
    assert priv_message1.owner_id == priv_message.owner_id
  end

  test "delete_priv_message/1 deletes the priv_message" do
    priv_message = insert(:priv_message)
    assert {:ok, %PrivMessage{}} = PrivMessages.delete_priv_message(priv_message)
    assert_raise Ecto.NoResultsError, fn -> PrivMessages.get_priv_message!(priv_message.priv_message_id) end
  end

  test "change_priv_message/1 returns a priv_message changeset" do
    priv_message = insert(:priv_message)
    assert %Ecto.Changeset{} = PrivMessages.change_priv_message(priv_message)
  end
end
