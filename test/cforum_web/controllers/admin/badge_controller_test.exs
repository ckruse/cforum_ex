defmodule CforumWeb.Admin.BadgeControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_login]

  describe "index" do
    test "lists all badges", %{conn: conn} do
      conn = get(conn, admin_badge_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("administrate badges")
    end
  end

  describe "new badge" do
    test "renders form", %{conn: conn} do
      conn = get(conn, admin_badge_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new badge")
    end
  end

  describe "create badge" do
    test "redirects to show when data is valid", %{conn: conn} do
      params = params_for(:badge)
      conn = post(conn, admin_badge_path(conn, :create), badge: params)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) == admin_badge_path(conn, :edit, id)

      conn = get(conn, admin_badge_path(conn, :edit, id))
      assert html_response(conn, 200) =~ gettext("edit badge „%{name}“", name: params[:name])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, admin_badge_path(conn, :create), badge: %{name: nil})
      assert html_response(conn, 200) =~ gettext("new badge")
    end
  end

  describe "edit badge" do
    setup [:create_badge]

    test "renders form for editing chosen badge", %{conn: conn, badge: badge} do
      conn = get(conn, admin_badge_path(conn, :edit, badge))
      assert html_response(conn, 200) =~ gettext("edit badge „%{name}“", name: badge.name)
    end
  end

  describe "update badge" do
    setup [:create_badge]

    test "redirects when data is valid", %{conn: conn, badge: badge} do
      conn = put(conn, admin_badge_path(conn, :update, badge), badge: %{name: "Rebellion"})
      assert redirected_to(conn) == admin_badge_path(conn, :edit, badge)

      conn = get(conn, admin_badge_path(conn, :edit, badge))
      assert html_response(conn, 200) =~ "Rebellion"
    end

    test "renders errors when data is invalid", %{conn: conn, badge: badge} do
      conn = put(conn, admin_badge_path(conn, :update, badge), badge: %{name: nil})
      assert html_response(conn, 200) =~ gettext("edit badge „%{name}“", name: badge.name)
    end
  end

  describe "delete badge" do
    setup [:create_badge]

    test "deletes chosen badge", %{conn: conn, badge: badge} do
      conn = delete(conn, admin_badge_path(conn, :delete, badge))
      assert redirected_to(conn) == admin_badge_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, admin_badge_path(conn, :edit, badge))
      end)
    end
  end

  defp create_badge(_), do: {:ok, badge: insert(:badge)}

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    {:ok, user: user, conn: login(conn, user)}
  end
end
