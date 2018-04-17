defmodule Cforum.GroupsTest do
  use Cforum.DataCase

  alias Cforum.Accounts.Groups

  describe "groups" do
    alias Cforum.Accounts.Group

    test "list_groups/0 returns all groups" do
      group = insert(:group)
      groups = Groups.list_groups()
      assert length(groups) == 1
      assert [%Group{}] = groups
      assert Enum.map(groups, & &1.group_id) == [group.group_id]
    end

    test "get_group!/1 returns the group with given id" do
      group = insert(:group)
      group1 = Groups.get_group!(group.group_id)
      assert %Group{} = group1
      assert group.group_id == group.group_id
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
      group1 = Groups.get_group!(group.group_id)
      assert %Group{} = group1
      assert group.name == group1.name
      assert group.group_id == group1.group_id
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
