defmodule Cforum.Accounts.UsersTest do
  use Cforum.DataCase

  alias Cforum.Accounts.Users
  alias Cforum.Accounts.User

  test "list_users/1 returns all users" do
    user = insert(:user)
    users = Users.list_users()
    assert length(users) == 1
    assert [%User{}] = users
    assert Enum.map(users, &(&1.user_id)) == [user.user_id]
  end

  test "get_user! returns the user with given id" do
    user = insert(:user)
    user1 = Users.get_user!(user.user_id)
    assert %User{} = user1
    assert user1.user_id == user.user_id
  end

  test "get_user_by_username_or_email returns the user with the given email" do
    user = insert(:user)
    user1 = Users.get_user_by_username_or_email(user.email)
    assert %User{} = user1
    assert user1.user_id == user.user_id
  end

  test "get_user_by_username_or_email returns the user with given email case insensitive" do
    user = insert(:user)
    user1 = Users.get_user_by_username_or_email(String.upcase(user.email))
    assert %User{} = user1
    assert user1.user_id == user.user_id
  end

  test "get_user_by_username_or_email returns the user with the given username" do
    user = insert(:user)
    user1 = Users.get_user_by_username_or_email(user.username)
    assert %User{} = user1
    assert user1.user_id == user.user_id
  end

  test "get_user_by_username_or_email returns the user with the given username case insensitive" do
    user = insert(:user)
    user1 = Users.get_user_by_username_or_email(String.upcase(user.username))
    assert %User{} = user1
    assert user1.user_id == user.user_id
  end

  test "create_user/1 with valid data creates a user" do
    params = params_for(:user)
    assert {:ok, %User{} = user} = Users.create_user(params)
    assert user.username == params[:username]
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Users.create_user(%{})
  end

  test "update_user/2 with valid data updates the user" do
    user = insert(:user)
    assert {:ok, user} = Users.update_user(user, %{username: "Luke"})
    assert %User{} = user
    assert user.username == "Luke"
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = insert(:user)
    assert {:error, %Ecto.Changeset{}} = Users.update_user(user, %{username: nil})

    user1 = Users.get_user!(user.user_id)
    assert %User{} = user1

    assert user.username == user1.username
  end

  test "delete_user/1 deletes the user" do
    user = insert(:user)
    assert {:ok, %User{}} = Users.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.user_id) end
  end

  test "change_user/1 returns a user changeset" do
    user = insert(:user)
    assert %Ecto.Changeset{} = Users.change_user(user)
  end
end
