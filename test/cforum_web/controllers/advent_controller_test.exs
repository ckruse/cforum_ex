defmodule CforumWeb.AdventControllerTest do
  use CforumWeb.ConnCase

  alias CforumWeb.Router.Helpers, as: Routes

  describe "index" do
    test "lists all advent calendar years", %{conn: conn} do
      conn = get(conn, Routes.advent_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("advent calendars")
    end
  end

  describe "show" do
    test "lists all advent_calendar_days", %{conn: conn} do
      conn = get(conn, Routes.advent_path(conn, :show, "2019"))
      assert html_response(conn, 200) =~ gettext("advent calendar %{year}", year: "2019")
    end
  end
end
