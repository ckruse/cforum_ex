defmodule Cforum.ForumsTest do
  use Cforum.DataCase

  alias Cforum.Forums

  describe "forums" do
    alias Cforum.Forums.Forum

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def forum_fixture(attrs \\ %{}) do
      {:ok, forum} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Forums.create_forum()

      forum
    end

    test "list_forums/0 returns all forums" do
      forum = forum_fixture()
      assert Forums.list_forums() == [forum]
    end

    test "get_forum!/1 returns the forum with given id" do
      forum = forum_fixture()
      assert Forums.get_forum!(forum.id) == forum
    end

    test "create_forum/1 with valid data creates a forum" do
      assert {:ok, %Forum{} = forum} = Forums.create_forum(@valid_attrs)
    end

    test "create_forum/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forums.create_forum(@invalid_attrs)
    end

    test "update_forum/2 with valid data updates the forum" do
      forum = forum_fixture()
      assert {:ok, forum} = Forums.update_forum(forum, @update_attrs)
      assert %Forum{} = forum
    end

    test "update_forum/2 with invalid data returns error changeset" do
      forum = forum_fixture()
      assert {:error, %Ecto.Changeset{}} = Forums.update_forum(forum, @invalid_attrs)
      assert forum == Forums.get_forum!(forum.id)
    end

    test "delete_forum/1 deletes the forum" do
      forum = forum_fixture()
      assert {:ok, %Forum{}} = Forums.delete_forum(forum)
      assert_raise Ecto.NoResultsError, fn -> Forums.get_forum!(forum.id) end
    end

    test "change_forum/1 returns a forum changeset" do
      forum = forum_fixture()
      assert %Ecto.Changeset{} = Forums.change_forum(forum)
    end
  end

  describe "messages" do
    alias Cforum.Forums.Message

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def message_fixture(attrs \\ %{}) do
      {:ok, message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Forums.create_message()

      message
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Forums.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Forums.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Forums.create_message(@valid_attrs)
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forums.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, message} = Forums.update_message(message, @update_attrs)
      assert %Message{} = message
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Forums.update_message(message, @invalid_attrs)
      assert message == Forums.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Forums.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Forums.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Forums.change_message(message)
    end
  end

  describe "tags" do
    alias Cforum.Forums.Tag

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def tag_fixture(attrs \\ %{}) do
      {:ok, tag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Forums.create_tag()

      tag
    end

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Forums.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Forums.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      assert {:ok, %Tag{} = tag} = Forums.create_tag(@valid_attrs)
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forums.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      assert {:ok, tag} = Forums.update_tag(tag, @update_attrs)
      assert %Tag{} = tag
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Forums.update_tag(tag, @invalid_attrs)
      assert tag == Forums.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Forums.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Forums.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Forums.change_tag(tag)
    end
  end

  describe "votes" do
    alias Cforum.Forums.Vote

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def vote_fixture(attrs \\ %{}) do
      {:ok, vote} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Forums.create_vote()

      vote
    end

    test "list_votes/0 returns all votes" do
      vote = vote_fixture()
      assert Forums.list_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = vote_fixture()
      assert Forums.get_vote!(vote.id) == vote
    end

    test "create_vote/1 with valid data creates a vote" do
      assert {:ok, %Vote{} = vote} = Forums.create_vote(@valid_attrs)
    end

    test "create_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forums.create_vote(@invalid_attrs)
    end

    test "update_vote/2 with valid data updates the vote" do
      vote = vote_fixture()
      assert {:ok, vote} = Forums.update_vote(vote, @update_attrs)
      assert %Vote{} = vote
    end

    test "update_vote/2 with invalid data returns error changeset" do
      vote = vote_fixture()
      assert {:error, %Ecto.Changeset{}} = Forums.update_vote(vote, @invalid_attrs)
      assert vote == Forums.get_vote!(vote.id)
    end

    test "delete_vote/1 deletes the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{}} = Forums.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Forums.get_vote!(vote.id) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = vote_fixture()
      assert %Ecto.Changeset{} = Forums.change_vote(vote)
    end
  end
end
