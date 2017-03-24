defmodule Cforum.BadgeController do
  use Cforum.Web, :controller

  alias Cforum.Badge

  def index(conn, _params) do
    badges = Repo.all(Badge)
    render(conn, "index.html", badges: badges)
  end

  def new(conn, _params) do
    changeset = Badge.changeset(%Badge{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"badge" => badge_params}) do
    changeset = Badge.changeset(%Badge{}, badge_params)

    case Repo.insert(changeset) do
      {:ok, _badge} ->
        conn
        |> put_flash(:info, "Badge created successfully.")
        |> redirect(to: badge_path(conn, :index, conn.assigns[:current_forum]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    badge = Repo.get!(Badge, id)
    render(conn, "show.html", badge: badge)
  end

  def edit(conn, %{"id" => id}) do
    badge = Repo.get!(Badge, id)
    changeset = Badge.changeset(badge)
    render(conn, "edit.html", badge: badge, changeset: changeset)
  end

  def update(conn, %{"id" => id, "badge" => badge_params}) do
    badge = Repo.get!(Badge, id)
    changeset = Badge.changeset(badge, badge_params)

    case Repo.update(changeset) do
      {:ok, badge} ->
        conn
        |> put_flash(:info, "Badge updated successfully.")
        |> redirect(to: badge_path(conn, :show, conn.assigns[:current_forum], badge))
      {:error, changeset} ->
        render(conn, "edit.html", badge: badge, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    badge = Repo.get!(Badge, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(badge)

    conn
    |> put_flash(:info, "Badge deleted successfully.")
    |> redirect(to: badge_path(conn, :index, conn.assigns[:current_forum]))
  end
end
