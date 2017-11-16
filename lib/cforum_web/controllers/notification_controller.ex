defmodule CforumWeb.NotificationController do
  use CforumWeb, :controller

  alias Cforum.Accounts.Notifications

  plug(:check_access)

  def index(conn, params) do
    {sort_params, conn} = sort_collection(conn, [:created_at, :subject, :is_read])
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
    notification = conn.assigns[:notification]

    # we ignore errors in this case; the user doesn't care, he just want's to
    # go to the referenced subject
    Notifications.update_notification(notification, %{is_read: false})
    redirect(conn, to: notification.path)
  end

  def update_unread(conn, %{"notification_id" => _id}) do
    notification = conn.assigns[:notification]

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

  def delete(conn, %{"id" => _id}) do
    Notifications.delete_notification(conn.assigns[:notification])

    conn
    |> put_flash(:info, gettext("Notification deleted successfully."))
    |> redirect(to: notification_path(conn, :index))
  end

  defp check_access(%Plug.Conn{params: %{"id" => id}} = conn, _) do
    notification = Notifications.get_notification!(id)

    if conn.assigns[:current_user] == nil || conn.assigns[:current_user].user_id != notification.recipient_id do
      CforumWeb.ErrorHandler.access_forbidden(conn, nil)
    else
      assign(conn, :notification, notification)
    end
  end

  defp check_access(conn, _), do: conn
end
