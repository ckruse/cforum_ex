defmodule CforumWeb.Admin.BadgeController do
  use CforumWeb, :controller

  alias Cforum.Accounts.{Badge, Badges}

  def index(conn, _params) do
    badges = Badges.list_badges()
    render(conn, "index.html", badges: badges)
  end

  def new(conn, _params) do
    changeset = Badges.change_badge(%Badge{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"badge" => badge_params}) do
    case Badges.create_badge(conn.assigns.current_user, badge_params) do
      {:ok, badge} ->
        conn
        |> put_flash(:info, gettext("Badge created successfully."))
        |> redirect(to: admin_badge_path(conn, :edit, badge))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    badge = Badges.get_badge!(id)
    changeset = Badges.change_badge(badge)
    render(conn, "edit.html", badge: badge, changeset: changeset)
  end

  def update(conn, %{"id" => id, "badge" => badge_params}) do
    badge = Badges.get_badge!(id)

    case Badges.update_badge(conn.assigns.current_user, badge, badge_params) do
      {:ok, badge} ->
        conn
        |> put_flash(:info, gettext("Badge updated successfully."))
        |> redirect(to: admin_badge_path(conn, :edit, badge))

      {:error, changeset} ->
        render(conn, "edit.html", badge: badge, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    badge = Badges.get_badge!(id)
    {:ok, _badge} = Badges.delete_badge(conn.assigns.current_user, badge)

    conn
    |> put_flash(:info, gettext("Badge deleted successfully."))
    |> redirect(to: admin_badge_path(conn, :index))
  end
end
