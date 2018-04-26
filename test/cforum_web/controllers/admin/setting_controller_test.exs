defmodule CforumWeb.Admin.SettingControllerTest do
  use CforumWeb.ConnCase
  alias Cforum.Accounts.{Setting, Settings}

  setup [:setup_login]

  test "edits with non-existing settings", %{conn: conn} do
    conn = get(conn, admin_setting_path(conn, :edit))
    assert html_response(conn, 200) =~ gettext("settings")
  end

  test "updates existing settings", %{conn: conn} do
    insert(:setting)
    conn = get(conn, admin_setting_path(conn, :edit))
    assert html_response(conn, 200) =~ gettext("settings")
  end

  test "creates new settings", %{conn: conn} do
    conn = put(conn, admin_setting_path(conn, :update), setting: %{options: %{}})
    assert redirected_to(conn) == admin_setting_path(conn, :edit)

    conn = get(conn, admin_setting_path(conn, :edit))
    assert html_response(conn, 200) =~ gettext("settings")

    setting = Settings.get_global_setting()
    assert setting
  end

  test "edits with existing settings", %{conn: conn} do
    insert(:setting)

    conn = put(conn, admin_setting_path(conn, :update), setting: %{options: %{"pagination" => 20}})
    assert redirected_to(conn) == admin_setting_path(conn, :edit)

    conn = get(conn, admin_setting_path(conn, :edit))
    assert html_response(conn, 200) =~ gettext("settings")

    setting = Settings.get_global_setting()
    assert %Setting{options: %{"pagination" => 20}} = setting
  end

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    {:ok, user: user, conn: login(conn, user)}
  end
end
