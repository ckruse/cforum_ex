defmodule Cforum.Accounts.SettingsTest do
  use Cforum.DataCase

  alias Cforum.Accounts.Settings
  alias Cforum.Accounts.Setting

  test "list_settings/2 returns all settings for a user" do
    setting = build(:setting) |> setting_with_user |> insert
    settings = Settings.list_settings(setting.user)
    assert length(settings) == 1
    assert [%Setting{}] = settings
    assert Enum.map(settings, & &1.setting_id) == [setting.setting_id]
  end

  test "get_setting!/1 returns the setting with given id" do
    setting = insert(:setting)
    setting1 = Settings.get_setting!(setting.setting_id)
    assert %Setting{} = setting1
    assert setting1.setting_id == setting.setting_id
  end

  test "get_setting_for_forum/1 returns the setting with given id" do
    setting = build(:setting) |> setting_with_forum |> insert
    setting1 = Settings.get_setting_for_forum(setting.forum)
    assert %Setting{} = setting1
    assert setting1.setting_id == setting.setting_id
  end

  test "create_setting/1 with valid data creates a setting" do
    params = params_for(:setting)
    assert {:ok, %Setting{}} = Settings.create_setting(params)
  end

  test "create_setting/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Settings.create_setting(%{})
  end

  test "update_setting/2 with valid data updates the setting" do
    setting = insert(:setting)
    assert {:ok, setting1} = Settings.update_setting(setting, %{options: %{"lulu" => "lala"}})
    assert %Setting{} = setting1
    assert setting1.options["lulu"] == "lala"
  end

  test "update_setting/2 with invalid data returns error changeset" do
    setting = insert(:setting)
    assert {:error, %Ecto.Changeset{}} = Settings.update_setting(setting, %{options: nil})
    setting1 = Settings.get_setting!(setting.setting_id)
    assert %Setting{} = setting1
    assert setting1.options == setting.options
  end

  test "delete_setting/1 deletes the setting" do
    setting = insert(:setting)
    assert {:ok, %Setting{}} = Settings.delete_setting(setting)
    assert_raise Ecto.NoResultsError, fn -> Settings.get_setting!(setting.setting_id) end
  end

  test "change_setting/1 returns a setting changeset" do
    setting = insert(:setting)
    assert %Ecto.Changeset{} = Settings.change_setting(setting)
  end

  test "load_relevant_settings/2 loads the global config when no user and no forum is given" do
    insert(:setting)
    ret = Settings.load_relevant_settings(nil, nil)
    assert [%Setting{forum_id: nil, user_id: nil}] = ret
  end

  test "load_relevant_settings/2 loads the global and the forum config" do
    insert(:setting)
    s = build(:setting) |> setting_with_forum |> insert

    ret = Settings.load_relevant_settings(s.forum, nil)
    assert [%Setting{forum_id: nil, user_id: nil}, %Setting{forum_id: fid}] = ret
    assert fid == s.forum_id
  end

  test "load_relevant_settings/2 loads the global and the user config" do
    insert(:setting)
    s = build(:setting) |> setting_with_user |> insert

    ret = Settings.load_relevant_settings(nil, s.user)
    assert [%Setting{forum_id: nil, user_id: nil}, %Setting{user_id: uid}] = ret
    assert uid == s.user_id
  end

  test "load_relevant_settings/2 loads the global, the forum and the user config" do
    insert(:setting)
    s = build(:setting) |> setting_with_forum |> insert
    s1 = build(:setting) |> setting_with_user |> insert

    ret = Settings.load_relevant_settings(s.forum, s1.user)
    assert [%Setting{forum_id: nil, user_id: nil}, %Setting{forum_id: fid}, %Setting{user_id: uid}] = ret
    assert fid == s.forum_id
    assert uid == s1.user_id
  end
end
