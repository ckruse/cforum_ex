defmodule Cforum.UsersTest do
  @moduledoc """
  Tests for the users API
  """

  use Cforum.DataCase
  use Cforum.Constants

  alias Cforum.Users
  alias Cforum.Users.User
  alias Cforum.Settings.Setting
  alias Cforum.Badges.Badge

  test "list_users/1 returns all users" do
    user = insert(:user)
    users = Users.list_users()
    assert length(users) == 1
    assert [%User{}] = users
    assert Enum.map(users, & &1.user_id) == [user.user_id]
  end

  test "get_user! returns the user with given id" do
    user = insert(:user)
    user1 = Users.get_user!(user.user_id)
    assert %User{} = user1
    assert user1.user_id == user.user_id
  end

  test "get_user! fails with invalid ID" do
    assert_raise Ecto.NoResultsError, fn -> Users.get_user!(-1) end
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

  test "get_user_by_username_or_email returns nil when nothing found" do
    user1 = Users.get_user_by_username_or_email("Bibbledibobble")
    assert user1 == nil
  end

  test "get_user_by_reset_password_token! returns a user by a given token" do
    user = insert(:user, reset_password_token: "foobar")
    user1 = Users.get_user_by_reset_password_token!("foobar")
    assert %User{} = user1
    assert user1.user_id == user.user_id
  end

  test "get_user_by_reset_password_token! fails on invalid tokens" do
    assert_raise Ecto.NoResultsError, fn -> Users.get_user_by_reset_password_token!("efwefwef") end
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

  test "delete_user/2 deletes the user" do
    user = insert(:user)
    assert {:ok, %User{}} = Users.delete_user(nil, user)
    assert %{success: 1, failure: 0, snoozed: 0} == Oban.drain_queue(queue: :background)
    assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.user_id) end
  end

  test "change_user/1 returns a user changeset" do
    user = insert(:user)
    assert %Ecto.Changeset{} = Users.change_user(user)
  end

  test "confirm_user/1 will actually confirm the user" do
    insert(:user, confirmed_at: nil, confirmation_token: "abc")
    assert {:ok, user} = Users.confirm_user("abc")

    assert user.confirmed_at
    refute user.confirmation_token
  end

  test "unique_badges should return an empty array when user has no badges" do
    user = insert(:user) |> Repo.preload(badges_users: :badges)
    assert Users.unique_badges(user) == []
  end

  test "unique_badges should return a list of unique user badges sorted by creation time" do
    badge = insert(:badge)
    user = insert(:user)

    insert(:badge_user, badge: badge, user: user)
    insert(:badge_user, badge: badge, user: user)

    user = Repo.preload(user, badges_users: :badge)
    assert [%{badge: %Badge{}, created_at: _, times: 2}] = Users.unique_badges(user)
  end

  test "conf will return default values for nil user" do
    assert Users.conf(nil, "pagination") == Cforum.ConfigManager.defaults()["pagination"]
  end

  test "conf will return default values for user w/o settings" do
    user =
      insert(:user)
      |> Repo.preload(:settings)

    assert Users.conf(user, "pagination") == Cforum.ConfigManager.defaults()["pagination"]
  end

  test "conf will return settings for user with a settings object" do
    user = build(:user, settings: %Setting{options: %{"pagination" => "60"}}) |> insert
    u = Users.get_user!(user.user_id)
    assert Users.conf(u, "pagination") == "60"
  end

  test "moderator? returns true for admins" do
    user = build(:user) |> as_admin |> insert
    assert Users.moderator?(user) == true
  end

  test "moderator? returns true for users with moderator badge" do
    badge = insert(:badge, badge_type: @badge_moderator_tools)
    user = insert(:user)
    insert(:badge_user, user: user, badge: badge)

    user = Cforum.Repo.preload(user, badges_users: :badge)

    assert Users.moderator?(user) == true
  end

  test "moderator? returns true for users with a moderator permission" do
    user = insert(:user, badges: [], badges_users: [])
    group = insert(:group, users: [user])
    insert(:forum_group_permission, permission: @permission_moderate, group: group)

    assert Users.moderator?(user) == true
  end

  test "moderator? returns false for normal users" do
    user = insert(:user, badges: [], badges_users: [])
    assert Users.moderator?(user) == false

    group = insert(:group, users: [user])
    insert(:forum_group_permission, permission: @permission_read, group: group)
    assert Users.moderator?(user) == false
  end
end
