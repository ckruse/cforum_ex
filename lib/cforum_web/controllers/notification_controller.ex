defmodule CforumWeb.NotificationController do
  use CforumWeb, :controller

  alias Cforum.Accounts.Notifications
  alias Cforum.Helpers

  alias CforumWeb.Sortable
  alias CforumWeb.Paginator

  def index(conn, params) do
    {sort_params, conn} = Sortable.sort_collection(conn, [:created_at, :subject])
    count = Notifications.count_notifications(conn.assigns[:current_user])
    paging = Paginator.paginate(count, page: params["p"])

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
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      Notifications.update_notification(conn.assigns.notification, %{is_read: false})
    end)

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

  def batch_action(conn, %{"batch_action" => action} = params) when action in ["mark_read", "mark_unread"] do
    {message, type} =
      case action do
        "mark_read" ->
          {gettext("Notifications successfully marked as read."), true}

        "mark_unread" ->
          {gettext("Notifications successfully marked as unread."), false}
      end

    Notifications.mark_notifications_as_read(conn.assigns[:current_user], params["notifications"], type)

    conn
    |> put_flash(:info, message)
    |> redirect(to: Routes.notification_path(conn, :index))
  end

  def batch_action(conn, %{"batch_action" => "delete"} = params) do
    Notifications.delete_notifications(conn.assigns[:current_user], params["notifications"])

    conn
    |> put_flash(:info, gettext("Notifications have successfully been deleted."))
    |> redirect(to: Routes.notification_path(conn, :index))
  end

  def load_resource(conn) do
    notification =
      cond do
        Helpers.present?(conn.params["notification_id"]) ->
          Notifications.get_notification!(conn.params["notification_id"])

        Helpers.present?(conn.params["id"]) ->
          Notifications.get_notification!(conn.params["id"])

        true ->
          nil
      end

    Plug.Conn.assign(conn, :notification, notification)
  end

  def allowed?(conn, action, _) when action in [:index, :batch_action], do: Abilities.signed_in?(conn)

  def allowed?(conn, _, ressource) do
    ressource = ressource || conn.assigns[:notification]
    Abilities.signed_in?(conn) && conn.assigns[:current_user].user_id == ressource.recipient_id
  end
end
