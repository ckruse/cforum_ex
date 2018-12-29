defmodule CforumWeb.Admin.BadgeControllerTest do
  use CforumWeb.ConnCase

  describe "index" do
    setup [:setup_login]

    test "lists all badges", %{conn: conn} do
      conn = get(conn, Routes.admin_badge_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("administrate badges")
    end
  end

  describe "new badge" do
    setup [:setup_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.admin_badge_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new badge")
    end
  end

  describe "create badge" do
    setup [:setup_login]

    test "redirects to show when data is valid", %{conn: conn} do
      params = params_for(:badge)
      conn = post(conn, Routes.admin_badge_path(conn, :create), badge: params)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_badge_path(conn, :edit, id)

      conn = get(conn, Routes.admin_badge_path(conn, :edit, id))
      assert html_response(conn, 200) =~ gettext("edit badge „%{name}“", name: params[:name])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_badge_path(conn, :create), badge: %{name: nil})
      assert html_response(conn, 200) =~ gettext("new badge")
    end
  end

  describe "edit badge" do
    setup [:setup_login, :create_badge]

    test "renders form for editing chosen badge", %{conn: conn, badge: badge} do
      conn = get(conn, Routes.admin_badge_path(conn, :edit, badge))
      assert html_response(conn, 200) =~ gettext("edit badge „%{name}“", name: badge.name)
    end
  end

  describe "update badge" do
    setup [:setup_login, :create_badge]

    test "redirects when data is valid", %{conn: conn, badge: badge} do
      conn = put(conn, Routes.admin_badge_path(conn, :update, badge), badge: %{name: "Rebellion"})
      assert redirected_to(conn) == Routes.admin_badge_path(conn, :edit, badge)

      conn = get(conn, Routes.admin_badge_path(conn, :edit, badge))
      assert html_response(conn, 200) =~ "Rebellion"
    end

    test "renders errors when data is invalid", %{conn: conn, badge: badge} do
      conn = put(conn, Routes.admin_badge_path(conn, :update, badge), badge: %{name: nil})
      assert html_response(conn, 200) =~ gettext("edit badge „%{name}“", name: badge.name)
    end
  end

  describe "delete badge" do
    setup [:setup_login, :create_badge]

    test "deletes chosen badge", %{conn: conn, badge: badge} do
      conn = delete(conn, Routes.admin_badge_path(conn, :delete, badge))
      assert redirected_to(conn) == Routes.admin_badge_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.admin_badge_path(conn, :edit, badge))
      end)
    end
  end

  describe "access rights" do
    test "anonymous isn't allowed to access", %{conn: conn} do
      assert_error_sent(403, fn -> get(conn, Routes.admin_badge_path(conn, :index)) end)
    end

    test "non-admin user isn't allowed to access", %{conn: conn} do
      user = insert(:user)
      conn = login(conn, user)
      assert_error_sent(403, fn -> get(conn, Routes.admin_badge_path(conn, :index)) end)
    end

    test "admin is allowed", %{conn: conn} do
      user = insert(:user, admin: true)

      conn =
        conn
        |> login(user)
        |> get(Routes.admin_badge_path(conn, :index))

      assert html_response(conn, 200) =~ gettext("administrate badges")
    end
  end

  defp create_badge(_), do: {:ok, badge: insert(:badge)}

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    {:ok, user: user, conn: login(conn, user)}
  end
end
