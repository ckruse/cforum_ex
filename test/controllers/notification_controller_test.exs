defmodule Cforum.NotificationControllerTest do
  use Cforum.Web.ConnCase

  alias Cforum.Notification
  @valid_attrs %{description: "some content", icon: "some content", is_read: true, oid: 42, otype: "some content", path: "some content", subject: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, notification_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing notifications"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, notification_path(conn, :new)
    assert html_response(conn, 200) =~ "New notification"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, notification_path(conn, :create), notification: @valid_attrs
    assert redirected_to(conn) == notification_path(conn, :index)
    assert Repo.get_by(Notification, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, notification_path(conn, :create), notification: @invalid_attrs
    assert html_response(conn, 200) =~ "New notification"
  end

  test "shows chosen resource", %{conn: conn} do
    notification = Repo.insert! %Notification{}
    conn = get conn, notification_path(conn, :show, notification)
    assert html_response(conn, 200) =~ "Show notification"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, notification_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    notification = Repo.insert! %Notification{}
    conn = get conn, notification_path(conn, :edit, notification)
    assert html_response(conn, 200) =~ "Edit notification"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    notification = Repo.insert! %Notification{}
    conn = put conn, notification_path(conn, :update, notification), notification: @valid_attrs
    assert redirected_to(conn) == notification_path(conn, :show, notification)
    assert Repo.get_by(Notification, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    notification = Repo.insert! %Notification{}
    conn = put conn, notification_path(conn, :update, notification), notification: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit notification"
  end

  test "deletes chosen resource", %{conn: conn} do
    notification = Repo.insert! %Notification{}
    conn = delete conn, notification_path(conn, :delete, notification)
    assert redirected_to(conn) == notification_path(conn, :index)
    refute Repo.get(Notification, notification.id)
  end
end
