defmodule CforumWeb.NotificationControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Accounts.Notifications

  setup [:setup_login]

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, Routes.notification_path(conn, :index))
    assert html_response(conn, 200) =~ gettext("Notifications")
  end

  test "redirects to notification ressource when showing", %{conn: conn, user: user} do
    notification = insert(:notification, recipient: user)
    conn = get(conn, Routes.notification_path(conn, :show, notification))

    assert redirected_to(conn) == notification.path
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn -> get(conn, Routes.notification_path(conn, :show, -1)) end)
  end

  test "marks a notification as unread", %{conn: conn, user: user} do
    notification = insert(:notification, is_read: true, recipient: user)
    conn = put(conn, Routes.notification_unread_path(conn, :update_unread, notification))

    assert redirected_to(conn) == Routes.notification_path(conn, :index)
    n1 = Notifications.get_notification!(notification.notification_id)
    assert n1.is_read == false
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    notification = insert(:notification, recipient: user)
    conn = delete(conn, Routes.notification_path(conn, :delete, notification))

    assert redirected_to(conn) == Routes.notification_path(conn, :index)
    assert_raise Ecto.NoResultsError, fn -> Notifications.get_notification!(notification.notification_id) end
  end

  test "ensure that one can't access foreign notifications", %{conn: conn} do
    notification = insert(:notification)
    assert_error_sent(403, fn -> get(conn, Routes.notification_path(conn, :show, notification)) end)
  end

  defp setup_login(%{conn: conn}) do
    user = insert(:user)
    {:ok, user: user, conn: login(conn, user)}
  end
end
