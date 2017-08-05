defmodule CforumWeb.NotificationController do
  use CforumWeb, :controller

  alias Cforum.Accounts.Notifications
  alias Cforum.Accounts.Notification

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
    notification = Repo.get!(Notification, id)
    render(conn, "show.html", notification: notification)
  end

  def delete(conn, %{"id" => id}) do
    notification = Repo.get!(Notification, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(notification)

    conn
    |> put_flash(:info, "Notification deleted successfully.")
    |> redirect(to: notification_path(conn, :index))
  end
end
