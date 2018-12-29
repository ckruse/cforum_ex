defmodule CforumWeb.EventControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_tests]

  test "lists events", %{conn: conn, event: event} do
    conn = get(conn, Routes.event_path(conn, :index))
    assert html_response(conn, 200) =~ gettext("events")
    assert html_response(conn, 200) =~ event.name
  end

  test "doesn't list hidden events", %{conn: conn, hidden_event: hidden_event} do
    conn = get(conn, Routes.event_path(conn, :index))
    assert html_response(conn, 200) =~ gettext("events")
    refute html_response(conn, 200) =~ hidden_event.name
  end

  test "shows an event", %{conn: conn, event: event} do
    conn = get(conn, Routes.event_path(conn, :show, event))
    assert html_response(conn, 200) =~ event.name
  end

  test "sends a 404 on hidden events", %{conn: conn, hidden_event: event} do
    assert_error_sent(404, fn -> get(conn, Routes.event_path(conn, :show, event)) end)
  end

  defp setup_tests(%{conn: conn}) do
    user = insert(:user)
    event = insert(:event, visible: true)
    hidden_event = insert(:event)
    {:ok, user: user, conn: login(conn, user), event: event, hidden_event: hidden_event}
  end
end
