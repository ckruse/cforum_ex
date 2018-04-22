defmodule Cforum.ConfigManagerTest do
  use Cforum.DataCase

  alias Cforum.Abilities.Helpers
  alias Cforum.Accounts.User

  describe "signed_in?/1 and admin?/1" do
    test "signed_in?/1 returns true if a user is signed in" do
      conn =
        %Plug.Conn{}
        |> Plug.Conn.assign(:current_user, %User{})

      assert Helpers.signed_in?(conn)
    end

    test "signed_in?/1 retuns false if no user is signed in" do
      conn = %Plug.Conn{}
      refute Helpers.signed_in?(conn)

      conn = Plug.Conn.assign(conn, :current_user, nil)
      refute Helpers.signed_in?(conn)
    end

    test "admin?/1 returns true for admin in conn" do
      conn =
        %Plug.Conn{}
        |> Plug.Conn.assign(:current_user, %User{admin: true})

      assert Helpers.admin?(conn)
    end

    test "admin?/1 returns true for admin user" do
      assert Helpers.admin?(%User{admin: true})
    end

    test "admin?/1 returns false for non-admin in conn" do
      conn =
        %Plug.Conn{}
        |> Plug.Conn.assign(:current_user, %User{admin: false})

      refute Helpers.admin?(conn)
    end

    test "admin?/1 returns false for non-admin user" do
      refute Helpers.admin?(%User{admin: false})
    end

    test "admin?/1 returns false for nil user" do
      refute Helpers.admin?(nil)
    end

    test "admin?/1 returns false for nil in conn" do
      refute Helpers.signed_in?(%Plug.Conn{})

      conn =
        %Plug.Conn{}
        |> Plug.Conn.assign(:current_user, nil)

      refute Helpers.signed_in?(conn)
    end
  end

  describe "access_forum?/3: read" do
    test "anonymous users may access read forums" do
      forum = insert(:forum, standard_permission: "read")
      assert Helpers.access_forum?(nil, forum, :read)
    end

    test "anonymous users may access write forums" do
      forum = insert(:forum, standard_permission: "write")
      assert Helpers.access_forum?(nil, forum, :read)
    end

    test "anonymous users may not access known-read forums" do
      forum = insert(:forum, standard_permission: "known-read")
      refute Helpers.access_forum?(nil, forum, :read)
    end

    test "anonymous users may not access known-write forums" do
      forum = insert(:forum, standard_permission: "known-write")
      refute Helpers.access_forum?(nil, forum, :read)
    end

    test "anonymous users may not access private forums" do
      forum = insert(:forum, standard_permission: "private")
      refute Helpers.access_forum?(nil, forum, :read)
    end

    test "users may access read forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "read")
      assert Helpers.access_forum?(user, forum, :read)
    end

    test "users may access write forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "write")
      assert Helpers.access_forum?(user, forum, :read)
    end

    test "users may access known-read forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "known-read")
      assert Helpers.access_forum?(user, forum, :read)
    end

    test "users may access known-write forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "known-write")
      assert Helpers.access_forum?(user, forum, :read)
    end

    test "users may not access private forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      refute Helpers.access_forum?(user, forum, :read)
    end

    test "user in group with read acess may read-access private forum" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "read", forum: forum, group: group)
      assert Helpers.access_forum?(user, forum, :read)
    end

    test "user in group with write acess may read-access private forum" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "write", forum: forum, group: group)
      assert Helpers.access_forum?(user, forum, :read)
    end

    test "user in group with moderate acess may read-access private forum" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "moderate", forum: forum, group: group)
      assert Helpers.access_forum?(user, forum, :read)
    end

    test "admin user may read-access private forum" do
      user = build(:user) |> as_admin |> insert
      forum = insert(:forum, standard_permission: "private")
      assert Helpers.access_forum?(user, forum, :read)
    end
  end

  describe "access_forum?/3: write" do
    test "anonymous users may not write-access read forums" do
      forum = insert(:forum, standard_permission: "read")
      refute Helpers.access_forum?(nil, forum, :write)
    end

    test "anonymous users may access write forums" do
      forum = insert(:forum, standard_permission: "write")
      assert Helpers.access_forum?(nil, forum, :write)
    end

    test "anonymous users may not write-access known-read forums" do
      forum = insert(:forum, standard_permission: "known-read")
      refute Helpers.access_forum?(nil, forum, :write)
    end

    test "anonymous users may not write-access known-write forums" do
      forum = insert(:forum, standard_permission: "known-write")
      refute Helpers.access_forum?(nil, forum, :write)
    end

    test "anonymous users may not write-access private forums" do
      forum = insert(:forum, standard_permission: "private")
      refute Helpers.access_forum?(nil, forum, :write)
    end

    test "users may not write-access read forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "read")
      refute Helpers.access_forum?(user, forum, :write)
    end

    test "users may write-access write forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "write")
      assert Helpers.access_forum?(user, forum, :write)
    end

    test "users may not write-access known-read forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "known-read")
      refute Helpers.access_forum?(user, forum, :write)
    end

    test "users may access known-write forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "known-write")
      assert Helpers.access_forum?(user, forum, :write)
    end

    test "users may not access private forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      refute Helpers.access_forum?(user, forum, :write)
    end

    test "user in group with read acess may not write-access private forum" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "read", forum: forum, group: group)
      refute Helpers.access_forum?(user, forum, :write)
    end

    test "user in group with write acess may write-access private forum" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "write", forum: forum, group: group)
      assert Helpers.access_forum?(user, forum, :write)
    end

    test "user in group with moderate acess may write-access private forum" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "moderate", forum: forum, group: group)
      assert Helpers.access_forum?(user, forum, :write)
    end

    test "user with read permission and moderator badge may write-access forum" do
      badge = insert(:badge, badge_type: "moderator_tools")
      user = insert(:user, badges: [badge])
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "read", forum: forum, group: group)
      assert Helpers.access_forum?(user, forum, :write)
    end

    test "admin user may read-access private forum" do
      user = build(:user) |> as_admin |> insert
      forum = insert(:forum, standard_permission: "private")
      assert Helpers.access_forum?(user, forum, :write)
    end
  end

  describe "access_forum?/3: moderate" do
    test "anonymous users may not moderate read forums" do
      forum = insert(:forum, standard_permission: "read")
      refute Helpers.access_forum?(nil, forum, :moderate)
    end

    test "anonymous users may moderate write forums" do
      forum = insert(:forum, standard_permission: "write")
      refute Helpers.access_forum?(nil, forum, :moderate)
    end

    test "anonymous users may not moderate known-read forums" do
      forum = insert(:forum, standard_permission: "known-read")
      refute Helpers.access_forum?(nil, forum, :moderate)
    end

    test "anonymous users may not moderate known-write forums" do
      forum = insert(:forum, standard_permission: "known-write")
      refute Helpers.access_forum?(nil, forum, :moderate)
    end

    test "anonymous users may not moderate private forums" do
      forum = insert(:forum, standard_permission: "private")
      refute Helpers.access_forum?(nil, forum, :moderate)
    end

    test "users may not moderate read forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "read")
      refute Helpers.access_forum?(user, forum, :moderate)
    end

    test "users may not moderate write forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "write")
      refute Helpers.access_forum?(user, forum, :moderate)
    end

    test "users may not moderate known-read forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "known-read")
      refute Helpers.access_forum?(user, forum, :moderate)
    end

    test "users may not moderate known-write forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "known-write")
      refute Helpers.access_forum?(user, forum, :moderate)
    end

    test "users may not moderate private forums" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      refute Helpers.access_forum?(user, forum, :moderate)
    end

    test "user in group with read acess may not moderate private forum" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "read", forum: forum, group: group)
      refute Helpers.access_forum?(user, forum, :moderate)
    end

    test "user in group with write acess may not moderate private forum" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "write", forum: forum, group: group)
      refute Helpers.access_forum?(user, forum, :moderate)
    end

    test "user in group with moderate acess may moderate private forum" do
      user = insert(:user)
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "moderate", forum: forum, group: group)
      assert Helpers.access_forum?(user, forum, :moderate)
    end

    test "user with read permission and moderator badge may moderate forum" do
      badge = insert(:badge, badge_type: "moderator_tools")
      user = insert(:user, badges: [badge])
      forum = insert(:forum, standard_permission: "private")
      group = insert(:group, users: [user])
      insert(:forum_group_permission, permission: "read", forum: forum, group: group)
      assert Helpers.access_forum?(user, forum, :moderate)
    end

    test "admin user may moderate private forum" do
      user = build(:user) |> as_admin |> insert
      forum = insert(:forum, standard_permission: "private")
      assert Helpers.access_forum?(user, forum, :moderate)
    end
  end
end
