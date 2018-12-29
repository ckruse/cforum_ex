defmodule CforumWeb.NotificationController do
  use CforumWeb, :controller

  alias Cforum.Accounts.Notifications

  def index(conn, params) do
    {sort_params, conn} = sort_collection(conn, [:created_at, :subject])
    count = Notifications.count_notifications(conn.assigns[:current_user])
    paging = CforumWeb.Paginator.paginate(count, page: params["p"])

    notifications =
      Notifications.list_notifications(
        conn.assigns[:current_user],
        limit: paging.params,
        order: sort_params
      )

    render(conn, "index.html", notifications: notifications, paging: paging)
  end

  def show(conn, %{"id" => _id}) do
    # we ignore errors in this case; the user doesn't care, he just want's to
    # go to the referenced subject
    Notifications.update_notification(conn.assigns.notification, %{is_read: false})
    redirect(conn, to: conn.assigns.notification.path)
  end

  def update_unread(conn, %{"notification_id" => _id}) do
    notification = conn.assigns.notification

    case Notifications.update_notification(notification, %{is_read: false}) do
      {:ok, _notification} ->
        conn
        |> put_flash(:info, gettext("Notification successfully marked as unread."))
        |> redirect(to: Routes.notification_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext("Oops, something went wrong!"))
        |> redirect(to: Routes.notification_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => _id}) do
    Notifications.delete_notification(conn.assigns[:notification])

    conn
    |> put_flash(:info, gettext("Notification deleted successfully."))
    |> redirect(to: Routes.notification_path(conn, :index))
  end

  def load_resource(conn) do
    notification =
      cond do
        !blank?(conn.params["notification_id"]) ->
          Notifications.get_notification!(conn.params["notification_id"])

        !blank?(conn.params["id"]) ->
          Notifications.get_notification!(conn.params["id"])

        true ->
          nil
      end

    Plug.Conn.assign(conn, :notification, notification)
  end

  def allowed?(conn, :index, _), do: signed_in?(conn)

  def allowed?(conn, _, ressource) do
    ressource = ressource || conn.assigns[:notification]
    signed_in?(conn) && conn.assigns[:current_user].user_id == ressource.recipient_id
  end
end
