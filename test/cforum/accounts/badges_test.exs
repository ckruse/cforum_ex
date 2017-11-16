defmodule Cforum.Accounts.BadgesTest do
  use Cforum.DataCase

  alias Cforum.Accounts.Badges
  alias Cforum.Accounts.Badge

  test "list_badges/2 returns all badges" do
    badge = insert(:badge)
    badges = Badges.list_badges()
    assert length(badges) == 1
    assert [%Badge{}] = badges
    assert Enum.map(badges, & &1.badge_id) == [badge.badge_id]
  end

  test "get_badge!/1 returns the badge with given id" do
    badge = insert(:badge)
    badge1 = Badges.get_badge!(badge.badge_id)
    assert %Badge{} = badge1
    assert badge1.badge_id == badge.badge_id
  end

  test "create_badge/1 with valid data creates a badge" do
    params = params_for(:badge)
    assert {:ok, %Badge{} = badge} = Badges.create_badge(params)
    assert badge.name == params[:name]
  end

  test "create_badge/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Badges.create_badge(%{})
  end

  test "update_badge/2 with valid data updates the badge" do
    badge = insert(:badge)
    assert {:ok, badge1} = Badges.update_badge(badge, %{name: "Foobar"})
    assert %Badge{} = badge1
    assert badge1.name == "Foobar"
  end

  test "update_badge/2 with invalid data returns error changeset" do
    badge = insert(:badge)
    assert {:error, %Ecto.Changeset{}} = Badges.update_badge(badge, %{name: nil})
    badge1 = Badges.get_badge!(badge.badge_id)
    assert %Badge{} = badge1
    assert badge1.name == badge.name
  end

  test "delete_badge/1 deletes the badge" do
    badge = insert(:badge)
    assert {:ok, %Badge{}} = Badges.delete_badge(badge)
    assert_raise Ecto.NoResultsError, fn -> Badges.get_badge!(badge.badge_id) end
  end

  test "change_badge/1 returns a badge changeset" do
    badge = insert(:badge)
    assert %Ecto.Changeset{} = Badges.change_badge(badge)
  end
end
