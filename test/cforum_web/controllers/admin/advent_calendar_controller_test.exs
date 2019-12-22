defmodule CforumWeb.DayControllerTest do
  use CforumWeb.ConnCase

  alias CforumWeb.Router.Helpers, as: Routes

  setup [:setup_login]

  describe "index_years" do
    test "lists all years with advent_calendar_days", %{conn: conn} do
      insert(:advent_calendar_day, date: %Date{year: 2019, month: 12, day: 1})
      insert(:advent_calendar_day, date: %Date{year: 2020, month: 12, day: 1})

      conn = get(conn, Routes.admin_advent_calendar_path(conn, :index_years))
      assert html_response(conn, 200) =~ gettext("administrate advent calendars")
    end
  end

  describe "index" do
    test "lists all advent_calendar_days", %{conn: conn} do
      conn = get(conn, Routes.admin_advent_calendar_path(conn, :index, "2019"))
      assert html_response(conn, 200) =~ gettext("administrate advent calendar %{year}", year: "2019")
    end
  end

  describe "new day" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.admin_advent_calendar_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new advent calendar day")
    end
  end

  describe "create day" do
    test "redirects to list when data is valid", %{conn: conn} do
      params = string_params_for(:advent_calendar_day)
      conn = post(conn, Routes.admin_advent_calendar_path(conn, :create), day: params)

      assert %{year: year} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_advent_calendar_path(conn, :index, year)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_advent_calendar_path(conn, :create), day: %{})
      assert html_response(conn, 200) =~ gettext("new advent calendar day")
    end
  end

  describe "edit day" do
    setup [:create_day]

    test "renders form for editing chosen day", %{conn: conn, day: day} do
      conn = get(conn, Routes.admin_advent_calendar_path(conn, :edit, day.date.year, day))
      assert html_response(conn, 200) =~ gettext("edit advent calendar day")
    end
  end

  describe "update day" do
    setup [:create_day]

    test "redirects when data is valid", %{conn: conn, day: day} do
      conn = put(conn, Routes.admin_advent_calendar_path(conn, :update, day.date.year, day), day: %{"subject" => "Foo"})
      assert redirected_to(conn) == Routes.admin_advent_calendar_path(conn, :index, day.date.year)

      conn = get(conn, Routes.admin_advent_calendar_path(conn, :edit, day.date.year, day))
      assert html_response(conn, 200) =~ "Foo"
    end

    test "renders errors when data is invalid", %{conn: conn, day: day} do
      conn = put(conn, Routes.admin_advent_calendar_path(conn, :update, day.date.year, day), day: %{subject: nil})
      assert html_response(conn, 200) =~ gettext("edit advent calendar day")
    end
  end

  describe "delete day" do
    setup [:create_day]

    test "deletes chosen day", %{conn: conn, day: day} do
      conn = delete(conn, Routes.admin_advent_calendar_path(conn, :delete, day.date.year, day))
      assert redirected_to(conn) == Routes.admin_advent_calendar_path(conn, :index, day.date.year)

      assert_error_sent 404, fn ->
        get(conn, Routes.admin_advent_calendar_path(conn, :edit, day.date.year, day))
      end
    end
  end

  defp create_day(_) do
    day = insert(:advent_calendar_day)
    {:ok, day: day}
  end

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    {:ok, user: user, conn: login(conn, user)}
  end
end
