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
end
