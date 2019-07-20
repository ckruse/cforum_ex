defmodule CforumWeb.Admin.EventControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Events.Event

  describe "index" do
    setup [:setup_login]

    test "lists all events", %{conn: conn} do
      conn = get(conn, Path.admin_event_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("administrate events")
    end
  end

  describe "new event" do
    setup [:setup_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, Path.admin_event_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new event")
    end
  end

  describe "create event" do
    setup [:setup_login]

    test "redirects to edit when data is valid", %{conn: conn} do
      params = params_for(:event)
      conn = post(conn, Path.admin_event_path(conn, :create), event: params)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) == Path.admin_event_path(conn, :edit, %Event{event_id: id})

      conn = get(conn, Path.admin_event_path(conn, :edit, %Event{event_id: id}))
      assert html_response(conn, 200) =~ gettext("edit event %{name}", name: params[:name])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Path.admin_event_path(conn, :create), event: %{})
      assert html_response(conn, 200) =~ gettext("new event")
    end
  end

  describe "edit event" do
    setup [:setup_login, :create_event]

    test "renders form for editing chosen event", %{conn: conn, event: event} do
      conn = get(conn, Path.admin_event_path(conn, :edit, event))
      assert html_response(conn, 200) =~ gettext("edit event %{name}", name: event.name)
    end
  end

  describe "update event" do
    setup [:setup_login, :create_event]

    test "redirects when data is valid", %{conn: conn, event: event} do
      conn = put(conn, Path.admin_event_path(conn, :update, event), event: %{name: "foo bar"})
      assert redirected_to(conn) == Path.admin_event_path(conn, :edit, event)

      conn = get(conn, Path.admin_event_path(conn, :edit, event))
      assert html_response(conn, 200) =~ "foo bar"
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put(conn, Path.admin_event_path(conn, :update, event), event: %{name: ""})
      assert html_response(conn, 200) =~ gettext("edit event %{name}", name: event.name)
    end
  end

  describe "delete event" do
    setup [:setup_login, :create_event]

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, Path.admin_event_path(conn, :delete, event))
      assert redirected_to(conn) == Path.admin_event_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Path.admin_event_path(conn, :edit, event))
      end)
    end
  end

  describe "access rights" do
    test "anonymous isn't allowed to access", %{conn: conn} do
      conn = get(conn, Path.admin_event_path(conn, :index))
      assert conn.status == 403
    end

    test "non-admin user isn't allowed to access", %{conn: conn} do
      user = insert(:user)
      conn = login(conn, user)
      conn = get(conn, Path.admin_event_path(conn, :index))
      assert conn.status == 403
    end

    test "admin is allowed", %{conn: conn} do
      user = insert(:user, admin: true)

      conn =
        conn
        |> login(user)
        |> get(Path.admin_event_path(conn, :index))

      assert html_response(conn, 200) =~ gettext("administrate events")
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
