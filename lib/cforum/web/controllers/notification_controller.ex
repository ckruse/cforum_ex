defmodule Cforum.Web.NotificationController do
  use Cforum.Web, :controller

  alias Cforum.Accounts.Notification

  def index(conn, _params) do
    notifications = Repo.all(Notification)
    render(conn, "index.html", notifications: notifications)
  end

  def new(conn, _params) do
    changeset = Notification.changeset(%Notification{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"notification" => notification_params}) do
    changeset = Notification.changeset(%Notification{}, notification_params)

    case Repo.insert(changeset) do
      {:ok, _notification} ->
        conn
        |> put_flash(:info, "Notification created successfully.")
        |> redirect(to: notification_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    notification = Repo.get!(Notification, id)
    render(conn, "show.html", notification: notification)
  end

  def edit(conn, %{"id" => id}) do
    notification = Repo.get!(Notification, id)
    changeset = Notification.changeset(notification)
    render(conn, "edit.html", notification: notification, changeset: changeset)
  end

  def update(conn, %{"id" => id, "notification" => notification_params}) do
    notification = Repo.get!(Notification, id)
    changeset = Notification.changeset(notification, notification_params)

    case Repo.update(changeset) do
      {:ok, notification} ->
        conn
        |> put_flash(:info, "Notification updated successfully.")
        |> redirect(to: notification_path(conn, :show, notification))
      {:error, changeset} ->
        render(conn, "edit.html", notification: notification, changeset: changeset)
    end
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
