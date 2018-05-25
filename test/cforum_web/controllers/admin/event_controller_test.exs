defmodule CforumWeb.Admin.EventControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_login]

  describe "index" do
    test "lists all events", %{conn: conn} do
      conn = get(conn, admin_event_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("events")
    end
  end

  describe "new event" do
    test "renders form", %{conn: conn} do
      conn = get(conn, admin_event_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new event")
    end
  end

  describe "create event" do
    test "redirects to edit when data is valid", %{conn: conn} do
      params = params_for(:event)
      conn = post(conn, admin_event_path(conn, :create), event: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == admin_event_path(conn, :edit, id)

      conn = get(conn, admin_event_path(conn, :edit, id))
      assert html_response(conn, 200) =~ gettext("edit event %{name}", name: params[:name])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, admin_event_path(conn, :create), event: %{})
      assert html_response(conn, 200) =~ gettext("new event")
    end
  end

  describe "edit event" do
    setup [:create_event]

    test "renders form for editing chosen event", %{conn: conn, event: event} do
      conn = get(conn, admin_event_path(conn, :edit, event))
      assert html_response(conn, 200) =~ gettext("edit event %{name}", name: event.name)
    end
  end

  describe "update event" do
    setup [:create_event]

    test "redirects when data is valid", %{conn: conn, event: event} do
      conn = put(conn, admin_event_path(conn, :update, event), event: %{name: "foo bar"})
      assert redirected_to(conn) == admin_event_path(conn, :edit, event)

      conn = get(conn, admin_event_path(conn, :edit, event))
      assert html_response(conn, 200) =~ "foo bar"
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put(conn, admin_event_path(conn, :update, event), event: %{name: ""})
      assert html_response(conn, 200) =~ gettext("edit event %{name}", name: event.name)
    end
  end

  describe "delete event" do
    setup [:create_event]

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, admin_event_path(conn, :delete, event))
      assert redirected_to(conn) == admin_event_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, admin_event_path(conn, :edit, event))
      end)
    end
  end

  defp create_event(_) do
    event = insert(:event)
    {:ok, event: event}
  end

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    {:ok, user: user, conn: login(conn, user)}
  end
end
