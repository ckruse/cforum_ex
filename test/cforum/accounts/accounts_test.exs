defmodule Cforum.AccountsTest do
  use Cforum.DataCase

  alias Cforum.Accounts

  describe "users" do
    alias Cforum.Accounts.User

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "priv_messages" do
    alias Cforum.Accounts.PrivMessages

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def priv_messages_fixture(attrs \\ %{}) do
      {:ok, priv_messages} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_priv_messages()

      priv_messages
    end

    test "list_priv_messages/0 returns all priv_messages" do
      priv_messages = priv_messages_fixture()
      assert Accounts.list_priv_messages() == [priv_messages]
    end

    test "get_priv_messages!/1 returns the priv_messages with given id" do
      priv_messages = priv_messages_fixture()
      assert Accounts.get_priv_messages!(priv_messages.id) == priv_messages
    end

    test "create_priv_messages/1 with valid data creates a priv_messages" do
      assert {:ok, %PrivMessages{} = priv_messages} = Accounts.create_priv_messages(@valid_attrs)
    end

    test "create_priv_messages/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_priv_messages(@invalid_attrs)
    end

    test "update_priv_messages/2 with valid data updates the priv_messages" do
      priv_messages = priv_messages_fixture()
      assert {:ok, priv_messages} = Accounts.update_priv_messages(priv_messages, @update_attrs)
      assert %PrivMessages{} = priv_messages
    end

    test "update_priv_messages/2 with invalid data returns error changeset" do
      priv_messages = priv_messages_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_priv_messages(priv_messages, @invalid_attrs)
      assert priv_messages == Accounts.get_priv_messages!(priv_messages.id)
    end

    test "delete_priv_messages/1 deletes the priv_messages" do
      priv_messages = priv_messages_fixture()
      assert {:ok, %PrivMessages{}} = Accounts.delete_priv_messages(priv_messages)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_priv_messages!(priv_messages.id) end
    end

    test "change_priv_messages/1 returns a priv_messages changeset" do
      priv_messages = priv_messages_fixture()
      assert %Ecto.Changeset{} = Accounts.change_priv_messages(priv_messages)
    end
  end

  describe "badges" do
    alias Cforum.Accounts.Badge

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def badge_fixture(attrs \\ %{}) do
      {:ok, badge} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_badge()

      badge
    end

    test "list_badges/0 returns all badges" do
      badge = badge_fixture()
      assert Accounts.list_badges() == [badge]
    end

    test "get_badge!/1 returns the badge with given id" do
      badge = badge_fixture()
      assert Accounts.get_badge!(badge.id) == badge
    end

    test "create_badge/1 with valid data creates a badge" do
      assert {:ok, %Badge{} = badge} = Accounts.create_badge(@valid_attrs)
    end

    test "create_badge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_badge(@invalid_attrs)
    end

    test "update_badge/2 with valid data updates the badge" do
      badge = badge_fixture()
      assert {:ok, badge} = Accounts.update_badge(badge, @update_attrs)
      assert %Badge{} = badge
    end

    test "update_badge/2 with invalid data returns error changeset" do
      badge = badge_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_badge(badge, @invalid_attrs)
      assert badge == Accounts.get_badge!(badge.id)
    end

    test "delete_badge/1 deletes the badge" do
      badge = badge_fixture()
      assert {:ok, %Badge{}} = Accounts.delete_badge(badge)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_badge!(badge.id) end
    end

    test "change_badge/1 returns a badge changeset" do
      badge = badge_fixture()
      assert %Ecto.Changeset{} = Accounts.change_badge(badge)
    end
  end

  describe "notifications" do
    alias Cforum.Accounts.Notification

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def notification_fixture(attrs \\ %{}) do
      {:ok, notification} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_notification()

      notification
    end

    test "list_notifications/0 returns all notifications" do
      notification = notification_fixture()
      assert Accounts.list_notifications() == [notification]
    end

    test "get_notification!/1 returns the notification with given id" do
      notification = notification_fixture()
      assert Accounts.get_notification!(notification.id) == notification
    end

    test "create_notification/1 with valid data creates a notification" do
      assert {:ok, %Notification{} = notification} = Accounts.create_notification(@valid_attrs)
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_notification(@invalid_attrs)
    end

    test "update_notification/2 with valid data updates the notification" do
      notification = notification_fixture()
      assert {:ok, notification} = Accounts.update_notification(notification, @update_attrs)
      assert %Notification{} = notification
    end

    test "update_notification/2 with invalid data returns error changeset" do
      notification = notification_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_notification(notification, @invalid_attrs)
      assert notification == Accounts.get_notification!(notification.id)
    end

    test "delete_notification/1 deletes the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{}} = Accounts.delete_notification(notification)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_notification!(notification.id) end
    end

    test "change_notification/1 returns a notification changeset" do
      notification = notification_fixture()
      assert %Ecto.Changeset{} = Accounts.change_notification(notification)
    end
  end

  describe "scores" do
    alias Cforum.Accounts.Score

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def score_fixture(attrs \\ %{}) do
      {:ok, score} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_score()

      score
    end

    test "list_scores/0 returns all scores" do
      score = score_fixture()
      assert Accounts.list_scores() == [score]
    end

    test "get_score!/1 returns the score with given id" do
      score = score_fixture()
      assert Accounts.get_score!(score.id) == score
    end

    test "create_score/1 with valid data creates a score" do
      assert {:ok, %Score{} = score} = Accounts.create_score(@valid_attrs)
    end

    test "create_score/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_score(@invalid_attrs)
    end

    test "update_score/2 with valid data updates the score" do
      score = score_fixture()
      assert {:ok, score} = Accounts.update_score(score, @update_attrs)
      assert %Score{} = score
    end

    test "update_score/2 with invalid data returns error changeset" do
      score = score_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_score(score, @invalid_attrs)
      assert score == Accounts.get_score!(score.id)
    end

    test "delete_score/1 deletes the score" do
      score = score_fixture()
      assert {:ok, %Score{}} = Accounts.delete_score(score)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_score!(score.id) end
    end

    test "change_score/1 returns a score changeset" do
      score = score_fixture()
      assert %Ecto.Changeset{} = Accounts.change_score(score)
    end
  end
end
