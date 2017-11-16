defmodule CforumWeb.NotificationControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Accounts.Notifications

  setup do
    {:ok, user: insert(:user)}
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    conn =
      login(conn, user)
      |> get(notification_path(conn, :index))

    assert html_response(conn, 200) =~ gettext("Notifications")
  end

  test "redirects to notification ressource when showing", %{conn: conn, user: user} do
    notification = insert(:notification)

    conn =
      login(conn, user)
      |> get(notification_path(conn, :show, notification))

    assert redirected_to(conn) == notification.path
  end

  test "renders page not found when id is nonexistent", %{conn: conn, user: user} do
    assert_error_sent(404, fn ->
      login(conn, user)
      |> get(notification_path(conn, :show, -1))
    end)
  end

  test "marks a notification as unread", %{conn: conn, user: user} do
    notification = insert(:notification, is_read: true)

    conn =
      login(conn, user)
      |> put(notification_unread_path(conn, :update_unread, notification))

    assert redirected_to(conn) == notification_path(conn, :index)
    n1 = Notifications.get_notification!(notification.notification_id)
    assert n1.is_read == false
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    notification = insert(:notification)

    conn =
      login(conn, user)
      |> delete(notification_path(conn, :delete, notification))

    assert redirected_to(conn) == notification_path(conn, :index)
    assert_raise Ecto.NoResultsError, fn -> Notifications.get_notification!(notification.notification_id) end
  end
end
