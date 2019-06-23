defmodule CforumWeb.BadgeControllerTest do
  use CforumWeb.ConnCase

  describe "index" do
    test "shows the index of badges", %{conn: conn} do
      badge = insert(:badge)
      conn = get(conn, Routes.badge_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("badges")
      assert html_response(conn, 200) =~ badge.name
    end
  end

  describe "show" do
    test "shows a single badge", %{conn: conn} do
      badge = insert(:badge, description: "foo bar")
      conn = get(conn, Path.badge_path(conn, :show, badge))
      assert html_response(conn, 200) =~ gettext("badge %{name}", name: badge.name)
    end
  end
end
