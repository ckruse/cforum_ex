defmodule CforumWeb.Admin.SettingControllerTest do
  use CforumWeb.ConnCase
  alias Cforum.Accounts.{Setting, Settings}

  describe "edit" do
    setup [:setup_login]

    test "edits with non-existing settings", %{conn: conn} do
      conn = get(conn, Path.admin_setting_path(conn, :edit))
      assert html_response(conn, 200) =~ gettext("settings")
    end

    test "edits with existing settings", %{conn: conn} do
      insert(:setting)

      conn = put(conn, Path.admin_setting_path(conn, :update), setting: %{options: %{"pagination" => 20}})
      assert redirected_to(conn) == Path.admin_setting_path(conn, :edit)

      conn = get(conn, Path.admin_setting_path(conn, :edit))
      assert html_response(conn, 200) =~ gettext("settings")

      setting = Settings.get_global_setting()
      assert %Setting{options: %{"pagination" => 20}} = setting
    end
  end

  describe "update" do
    setup [:setup_login]

    test "updates existing settings", %{conn: conn} do
      insert(:setting)
      conn = get(conn, Path.admin_setting_path(conn, :edit))
      assert html_response(conn, 200) =~ gettext("settings")
    end
  end

  describe "create" do
    setup [:setup_login]

    test "creates new settings", %{conn: conn} do
      conn = put(conn, Path.admin_setting_path(conn, :update), setting: %{options: %{}})
      assert redirected_to(conn) == Path.admin_setting_path(conn, :edit)

      conn = get(conn, Path.admin_setting_path(conn, :edit))
      assert html_response(conn, 200) =~ gettext("settings")

      setting = Settings.get_global_setting()
      assert setting
    end
  end

  describe "access rights" do
    test "anonymous isn't allowed to access", %{conn: conn} do
      conn = get(conn, Path.admin_setting_path(conn, :edit))
      assert conn.status == 403
    end

    test "non-admin user isn't allowed to access", %{conn: conn} do
      user = insert(:user)
      conn = login(conn, user)
      conn = get(conn, Path.admin_setting_path(conn, :edit))
      assert conn.status == 403
    end

    test "admin is allowed", %{conn: conn} do
      user = insert(:user, admin: true)

      conn =
        conn
        |> login(user)
        |> get(Path.admin_setting_path(conn, :edit))

      assert html_response(conn, 200) =~ gettext("settings")
    end
  end

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    {:ok, user: user, conn: login(conn, user)}
  end
end
