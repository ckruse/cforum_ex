defmodule CforumWeb.Events.AttendeeControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Events.Event

  describe "new attendee" do
    setup [:setup_tests]

    test "renders form", %{conn: conn, event: event, user: user} do
      conn =
        conn
        |> login(user)
        |> get(Path.event_attendee_path(conn, :new, event))

      assert html_response(conn, 200) =~ gettext("take place in event „%{event}“", event: event.name)
    end
  end

  describe "create attendee" do
    setup [:setup_tests]

    test "redirects to event#show when data is valid", %{conn: conn, event: event} do
      attrs = params_for(:attendee, event: event)
      conn = post(conn, Path.event_attendee_path(conn, :create, event), attendee: attrs)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) =~ Path.event_path(conn, :show, %Event{event_id: id})

      conn = get(conn, Path.event_path(conn, :show, %Event{event_id: id}))
      assert html_response(conn, 200) =~ attrs[:name]
    end

    test "doesn't need a name when logged in", %{conn: conn, user: user, event: event} do
      attrs = params_for(:attendee, event: event) |> Map.delete(:name)

      conn =
        conn
        |> login(user)
        |> post(Path.event_attendee_path(conn, :create, event), attendee: attrs)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) =~ Path.event_path(conn, :show, %Event{event_id: id})

      conn = get(conn, Path.event_path(conn, :show, %Event{event_id: id}))
      assert html_response(conn, 200) =~ user.username
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = post(conn, Path.event_attendee_path(conn, :create, event), attendee: %{})
      assert html_response(conn, 200) =~ gettext("take place in event „%{event}“", event: event.name)
    end
  end

  describe "edit cite" do
    setup [:setup_tests, :create_attendee]

    test "renders form for editing an attendee", %{conn: conn, event: event, admin: admin, attendee: attendee} do
      conn =
        conn
        |> login(admin)
        |> get(Path.event_attendee_path(conn, :edit, event, attendee))

      assert html_response(conn, 200) =~
               gettext(
                 "take place in event „%{event}“: attendee „%{attendee}“",
                 event: event.name,
                 attendee: attendee.name
               )
    end
  end

  describe "update attendee" do
    setup [:setup_tests, :create_attendee]

    test "redirects when data is valid", %{conn: conn, event: event, admin: admin, attendee: attendee} do
      conn =
        conn
        |> login(admin)
        |> put(Path.event_attendee_path(conn, :update, event, attendee), attendee: %{name: "Luke Skywalker"})

      assert redirected_to(conn) == Path.event_path(conn, :show, event)

      conn = get(conn, Path.event_path(conn, :show, event))
      assert html_response(conn, 200) =~ "Luke Skywalker"
    end

    test "renders errors when data is invalid", %{conn: conn, event: event, admin: admin, attendee: attendee} do
      conn =
        conn
        |> login(admin)
        |> put(Path.event_attendee_path(conn, :update, event, attendee), attendee: %{name: nil})

      assert html_response(conn, 200) =~
               gettext(
                 "take place in event „%{event}“: attendee „%{attendee}“",
                 event: event.name,
                 attendee: attendee.name
               )
    end
  end

  describe "delete attendee" do
    setup [:setup_tests, :create_attendee]

    test "deletes chosen attendee", %{conn: conn, event: event, attendee: attendee, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> delete(Path.event_attendee_path(conn, :delete, event, attendee))

      assert redirected_to(conn) == Path.event_path(conn, :show, event)
      assert_error_sent(404, fn -> get(conn, Path.event_attendee_path(conn, :edit, event, attendee)) end)
    end
  end

  describe "access rights" do
    setup [:setup_tests, :create_attendee]

    test "new is allowed as anonymous", %{conn: conn, event: event} do
      conn = get(conn, Path.event_attendee_path(conn, :new, event))
      assert html_response(conn, 200) =~ gettext("take place in event „%{event}“", event: event.name)
    end

    test "new is allowed as logged in user", %{conn: conn, event: event, user1: user} do
      conn =
        conn
        |> login(user)
        |> get(Path.event_attendee_path(conn, :new, event))

      assert html_response(conn, 200) =~ gettext("take place in event „%{event}“", event: event.name)
    end

    test "new isn't allowed as logged in user when already attending", %{conn: conn, event: event, user: user} do
      conn =
        conn
        |> login(user)
        |> get(Path.event_attendee_path(conn, :new, event))

      assert conn.status == 403
    end

    test "responds with 403 on invisible event", %{conn: conn, hidden_event: event} do
      conn = get(conn, Path.event_attendee_path(conn, :new, event))
      assert conn.status == 403
    end

    test "create is allowed as anonymous", %{conn: conn, event: event} do
      attrs = params_for(:attendee, event: event)
      conn = post(conn, Path.event_attendee_path(conn, :create, event), attendee: attrs)
      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) =~ Path.event_path(conn, :show, %Event{event_id: id})
    end

    test "create is allowed as logged in user", %{conn: conn, user1: user, event: event} do
      attrs = params_for(:attendee, event: event)

      conn =
        conn
        |> login(user)
        |> post(Path.event_attendee_path(conn, :create, event), attendee: attrs)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) =~ Path.event_path(conn, :show, %Event{event_id: id})
    end

    test "edit is not allowed for anonymous users", %{conn: conn, event: event, attendee: attendee} do
      conn = get(conn, Path.event_attendee_path(conn, :edit, event, attendee))
      assert conn.status == 403
    end

    test "edit is allowed for logged in users", %{conn: conn, user: user, event: event, attendee: attendee} do
      conn =
        conn
        |> login(user)
        |> get(Path.event_attendee_path(conn, :edit, event, attendee))

      assert html_response(conn, 200)
    end

    test "edit is not allowed for logged in users on foreign attendees", %{conn: conn, event: event, user: user} do
      attendee = insert(:attendee, event: event)
      conn = get(login(conn, user), Path.event_attendee_path(conn, :edit, event, attendee))
      assert conn.status == 403
    end

    test "edit is allowed for admins on foreign attendees", %{conn: conn, event: event, attendee: attendee, admin: user} do
      conn =
        conn
        |> login(user)
        |> get(Path.event_attendee_path(conn, :edit, event, attendee))

      assert html_response(conn, 200)
    end
  end

  defp create_attendee(%{event: event, user: user}) do
    attendee = insert(:attendee, event: event, user: user)
    {:ok, attendee: attendee}
  end

  defp setup_tests(_) do
    user = insert(:user)
    user1 = insert(:user)
    admin = build(:user) |> as_admin() |> insert()
    event = insert(:event, visible: true)
    hidden_event = insert(:event)

    {:ok, user: user, user1: user1, admin: admin, event: event, hidden_event: hidden_event}
  end
end
