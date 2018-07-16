defmodule CforumWeb.Events.AttendeeControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_tests]

  describe "new attendee" do
    test "renders form as logged in user", %{conn: conn, event: event, user: user} do
      conn =
        conn
        |> login(user)
        |> get(event_attendee_path(conn, :new, event))

      assert html_response(conn, 200) =~ gettext("take place in event „%{event}“", event: event.name)
    end

    test "renders form as anonymous user", %{conn: conn, event: event} do
      conn = get(conn, event_attendee_path(conn, :new, event))
      assert html_response(conn, 200) =~ gettext("take place in event „%{event}“", event: event.name)
    end

    test "responds with 403 on invisible event", %{conn: conn, hidden_event: event} do
      assert_error_sent(403, fn -> get(conn, event_attendee_path(conn, :new, event)) end)
    end
  end

  describe "create attendee" do
    test "redirects to event#show when data is valid", %{conn: conn, event: event} do
      attrs = params_for(:attendee, event: event)
      conn = post(conn, event_attendee_path(conn, :create, event), attendee: attrs)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) =~ event_path(conn, :show, id)

      conn = get(conn, event_path(conn, :show, id))
      assert html_response(conn, 200) =~ attrs[:name]
    end

    test "doesn't need a name when logged in", %{conn: conn, user: user, event: event} do
      attrs = params_for(:attendee, event: event) |> Map.delete(:name)

      conn =
        conn
        |> login(user)
        |> post(event_attendee_path(conn, :create, event), attendee: attrs)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) =~ event_path(conn, :show, id)

      conn = get(conn, event_path(conn, :show, id))
      assert html_response(conn, 200) =~ user.username
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = post(conn, event_attendee_path(conn, :create, event), attendee: %{})
      assert html_response(conn, 200) =~ gettext("take place in event „%{event}“", event: event.name)
    end
  end

  describe "edit cite" do
    setup [:create_attendee]

    test "renders form for editing an attendee", %{conn: conn, event: event, admin: admin, attendee: attendee} do
      conn =
        conn
        |> login(admin)
        |> get(event_attendee_path(conn, :edit, event, attendee))

      assert html_response(conn, 200) =~
               gettext(
                 "take place in event „%{event}“: attendee „%{attendee}“",
                 event: event.name,
                 attendee: attendee.name
               )
    end
  end

  describe "update attendee" do
    setup [:create_attendee]

    test "redirects when data is valid", %{conn: conn, event: event, admin: admin, attendee: attendee} do
      conn =
        conn
        |> login(admin)
        |> put(event_attendee_path(conn, :update, event, attendee), attendee: %{name: "Luke Skywalker"})

      assert redirected_to(conn) == event_path(conn, :show, event)

      conn = get(conn, event_path(conn, :show, event))
      assert html_response(conn, 200) =~ "Luke Skywalker"
    end

    test "renders errors when data is invalid", %{conn: conn, event: event, admin: admin, attendee: attendee} do
      conn =
        conn
        |> login(admin)
        |> put(event_attendee_path(conn, :update, event, attendee), attendee: %{name: nil})

      assert html_response(conn, 200) =~
               gettext(
                 "take place in event „%{event}“: attendee „%{attendee}“",
                 event: event.name,
                 attendee: attendee.name
               )
    end
  end

  describe "delete attendee" do
    setup [:create_attendee]

    test "deletes chosen attendee", %{conn: conn, event: event, attendee: attendee, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> delete(event_attendee_path(conn, :delete, event, attendee))

      assert redirected_to(conn) == event_path(conn, :show, event)
      assert_error_sent(404, fn -> get(conn, event_attendee_path(conn, :edit, event, attendee)) end)
    end
  end

  defp create_attendee(%{event: event}) do
    attendee = insert(:attendee, event: event)
    {:ok, attendee: attendee}
  end

  defp setup_tests(_) do
    user = insert(:user)
    admin = build(:user) |> as_admin() |> insert()
    event = insert(:event, visible: true)
    hidden_event = insert(:event)

    {:ok, user: user, admin: admin, event: event, hidden_event: hidden_event}
  end
end
