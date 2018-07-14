defmodule Cforum.ForumsTest do
  use Cforum.DataCase

  alias Cforum.Forums
  alias Cforum.Forums.Forum

  setup do
    user = insert(:user, admin: false)
    admin = insert(:user, admin: true)
    {:ok, user: user, admin: admin}
  end

  test "list_forums/0 returns all forums" do
    forum = insert(:forum)
    assert Forums.list_forums() == [forum]
  end

  test "get_forum!/1 returns the forum with given id" do
    forum = insert(:forum)
    assert Forums.get_forum!(forum.forum_id) == forum
  end

  test "create_forum/1 with valid data creates a forum", %{user: user} do
    params = params_for(:forum)
    assert {:ok, %Forum{} = forum} = Forums.create_forum(user, params)
    assert forum.name == params[:name]
    assert forum.short_name == params[:short_name]
  end

  test "create_forum/1 with invalid data returns error changeset", %{user: user} do
    assert {:error, %Ecto.Changeset{}} = Forums.create_forum(user, %{})
  end

  test "update_forum/2 with valid data updates the forum", %{user: user} do
    forum = insert(:forum)
    assert {:ok, forum} = Forums.update_forum(user, forum, %{name: "Rebellion on my mind"})
    assert %Forum{} = forum
    assert forum.name == "Rebellion on my mind"
  end

  test "update_forum/2 with invalid data returns error changeset", %{user: user} do
    forum = insert(:forum)
    assert {:error, %Ecto.Changeset{}} = Forums.update_forum(user, forum, %{name: ""})
    assert forum == Forums.get_forum!(forum.forum_id)
  end

  test "delete_forum/1 deletes the forum", %{user: user} do
    forum = insert(:forum)
    assert {:ok, %Forum{}} = Forums.delete_forum(user, forum)
    assert_raise Ecto.NoResultsError, fn -> Forums.get_forum!(forum.forum_id) end
  end

  test "change_forum/1 returns a forum changeset" do
    forum = insert(:forum)
    assert %Ecto.Changeset{} = Forums.change_forum(forum)
  end

  describe "visible forums" do
    test "visible_forums/1 returns no private forums for anonymous users" do
      insert(:forum, standard_permission: "private")
      assert Forums.list_visible_forums() == []
    end

    test "visible_forums/1 returns no known-read forums for anonymous users" do
      insert(:forum, standard_permission: "known-read")
      assert Forums.list_visible_forums() == []
    end

    test "visible_forums/1 returns no known-write forums for anonymous users" do
      insert(:forum, standard_permission: "known-write")
      assert Forums.list_visible_forums() == []
    end

    test "visible_forums/1 returns all read forums for anonymous users" do
      forum = insert(:forum, standard_permission: "read")
      assert Forums.list_visible_forums() == [forum]
    end

    test "visible_forums/1 returns all write forums for anonymous users" do
      forum = insert(:forum, standard_permission: "write")
      assert Forums.list_visible_forums() == [forum]
    end

    test "visible_forums/1 returns all forums for admins", %{admin: admin} do
      priv_forum = insert(:forum, standard_permission: "private")
      known_read_forum = insert(:forum, standard_permission: "known-read")
      known_write_forum = insert(:forum, standard_permission: "known-write")
      read_forum = insert(:forum, standard_permission: "read")
      write_forum = insert(:forum, standard_permission: "write")

      assert Forums.list_visible_forums(admin) == [
               priv_forum,
               known_read_forum,
               known_write_forum,
               read_forum,
               write_forum
             ]
    end

    test "visible_forums/1 returns no private forums for normal users", %{user: user} do
      insert(:forum, standard_permission: "private")
      assert Forums.list_visible_forums(user) == []
    end

    test "visible_forums/1 returns all known-read forums for normal users", %{user: user} do
      forum = insert(:forum, standard_permission: "known-read")
      assert Forums.list_visible_forums(user) == [forum]
    end

    test "visible_forums/1 returns all known-write forums for normal users", %{user: user} do
      forum = insert(:forum, standard_permission: "known-write")
      assert Forums.list_visible_forums(user) == [forum]
    end

    test "visible_forums/1 returns all read forums for normal users", %{user: user} do
      forum = insert(:forum, standard_permission: "read")
      assert Forums.list_visible_forums(user) == [forum]
    end

    test "visible_forums/1 returns all write forums for normal users", %{user: user} do
      forum = insert(:forum, standard_permission: "write")
      assert Forums.list_visible_forums(user) == [forum]
    end

    test "visible_forums/1 returns all forums by permission for grouped users", %{user: user} do
      group = insert(:group, users: [user])
      forum = insert(:forum, standard_permission: "private")
      insert(:forum_group_permission, group: group, forum: forum)
      assert Forums.list_visible_forums(user) == [forum]
    end
  end

  describe "list forums by permission" do
    test "list_forums_by_permission/2 lists all forums for admins", %{admin: admin} do
      forum = insert(:forum, standard_permission: "private")
      forum1 = insert(:forum, standard_permission: "write")

      assert Forums.list_forums_by_permission(admin, "moderate") == [forum, forum1]
      assert Forums.list_forums_by_permission(admin, "write") == [forum, forum1]
      assert Forums.list_forums_by_permission(admin, "read") == [forum, forum1]
    end

    test "list_forums_by_permission/2 lists all forums for normal users", %{user: user} do
      insert(:forum, standard_permission: "private")
      mod_forum = insert(:forum, standard_permission: "private")
      write_forum = insert(:forum, standard_permission: "private")
      read_forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])

      insert(:forum_group_permission, group: group, forum: mod_forum, permission: "moderate")
      insert(:forum_group_permission, group: group, forum: write_forum, permission: "write")
      insert(:forum_group_permission, group: group, forum: read_forum, permission: "read")

      assert Forums.list_forums_by_permission(user, "moderate") == [mod_forum]
      assert Forums.list_forums_by_permission(user, "write") == [mod_forum, write_forum]
      assert Forums.list_forums_by_permission(user, "read") == [mod_forum, write_forum, read_forum]
    end

    test "list_forums_by_permission/2 lists all standard permission forums for normal users", %{user: user} do
      insert(:forum, standard_permission: "private")
      known_write_forum = insert(:forum, standard_permission: "known-write")
      known_read_forum = insert(:forum, standard_permission: "known-read")
      write_forum = insert(:forum, standard_permission: "write")
      read_forum = insert(:forum, standard_permission: "read")

      assert Forums.list_forums_by_permission(user, "moderate") == []
      assert Forums.list_forums_by_permission(user, "write") == [known_write_forum, write_forum]

      assert Forums.list_forums_by_permission(user, "read") == [
               known_write_forum,
               known_read_forum,
               write_forum,
               read_forum
             ]
    end

    test "list_forums_by_permission/2 only lists standard permission forums for anonymous" do
      insert(:forum, standard_permission: "private")
      insert(:forum, standard_permission: "known-write")
      insert(:forum, standard_permission: "known-read")

      write_forum = insert(:forum, standard_permission: "write")
      read_forum = insert(:forum, standard_permission: "read")

      assert Forums.list_forums_by_permission(nil, "write") == [write_forum]
      assert Forums.list_forums_by_permission(nil, "read") == [write_forum, read_forum]
    end
  end
end
