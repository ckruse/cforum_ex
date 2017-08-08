defmodule CforumWeb.NotificationController do
  use CforumWeb, :controller

  alias Cforum.Accounts.Notifications

  def index(conn, params) do
    {sort_params, conn} = sort_collection(conn, [:created_at, :subject, :is_read])
    count = Notifications.count_notifications(conn.assigns[:current_user])
    paging = CforumWeb.Paginator.paginate(count, page: params["p"])
    notifications = Notifications.list_notifications(
      conn.assigns[:current_user],
      limit: paging.params,
      order: sort_params
    )

    render(conn, "index.html", notifications: notifications, paging: paging)
  end

  def show(conn, %{"id" => id}) do
    notification = Notifications.get_notification!(id)
    render(conn, "show.html", notification: notification)
  end

  def update_unread(conn, %{"notification_id" => id}) do
    notification = Notifications.get_notification!(id)

    case Notifications.update_notification(notification, %{is_read: false}) do
      {:ok, _notification} ->
        conn
        |> put_flash(:info, gettext("Notification successfully marked as unread."))
        |> redirect(to: notification_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext("Oops, something went wrong!"))
        |> redirect(to: notification_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    notification = Notifications.get_notification!(id)
    Notifications.delete_notification(notification)

    conn
    |> put_flash(:info, gettext("Notification deleted successfully."))
    |> redirect(to: notification_path(conn, :index))
  end
end
