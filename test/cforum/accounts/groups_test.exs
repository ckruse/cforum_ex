defmodule Cforum.GroupsTest do
  use Cforum.DataCase

  alias Cforum.Accounts.Groups

  describe "groups" do
    alias Cforum.Accounts.Group

    test "list_groups/0 returns all groups" do
      group = insert(:group)
      assert Groups.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = insert(:group)
      assert Groups.get_group!(group.group_id) == group
    end

    test "create_group/1 with valid data creates a group" do
      p = params_for(:group)
      assert {:ok, %Group{} = group} = Groups.create_group(p)
      assert group.name == p[:name]
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(%{name: nil})
    end

    test "update_group/2 with valid data updates the group" do
      group = insert(:group)
      assert {:ok, group} = Groups.update_group(group, %{name: "Foo"})
      assert %Group{} = group
      assert group.name == "Foo"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = insert(:group)
      assert {:error, %Ecto.Changeset{}} = Groups.update_group(group, %{name: nil})
      assert group == Groups.get_group!(group.group_id)
    end

    test "delete_group/1 deletes the group" do
      group = insert(:group)
      assert {:ok, %Group{}} = Groups.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_group!(group.group_id) end
    end

    test "change_group/1 returns a group changeset" do
      group = insert(:group)
      assert %Ecto.Changeset{} = Groups.change_group(group)
    end
  end
end
