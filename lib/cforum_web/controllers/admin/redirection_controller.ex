defmodule CforumWeb.Admin.RedirectionController do
  use CforumWeb, :controller

  alias Cforum.System
  alias Cforum.System.Redirection

  def index(conn, params) do
    {sort_params, conn} = sort_collection(conn, [:redirection_id, :path, :destination], dir: :desc)
    count = System.count_redirections()
    paging = paginate(count, page: params["p"])
    redirections = System.list_redirections(limit: paging.params, order: sort_params)
    render(conn, "index.html", redirections: redirections, paging: paging)
  end

  def new(conn, _params) do
    changeset = System.change_redirection(%Redirection{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"redirection" => redirection_params}) do
    case System.create_redirection(conn.assigns.current_user, redirection_params) do
      {:ok, redirection} ->
        conn
        |> put_flash(:info, gettext("Redirection created successfully."))
        |> redirect(to: Routes.admin_redirection_path(conn, :edit, redirection))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    redirection = System.get_redirection!(id)
    changeset = System.change_redirection(redirection)
    render(conn, "edit.html", redirection: redirection, changeset: changeset)
  end

  def update(conn, %{"id" => id, "redirection" => redirection_params}) do
    redirection = System.get_redirection!(id)

    case System.update_redirection(conn.assigns.current_user, redirection, redirection_params) do
      {:ok, redirection} ->
        conn
        |> put_flash(:info, gettext("Redirection updated successfully."))
        |> redirect(to: Routes.admin_redirection_path(conn, :edit, redirection))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", redirection: redirection, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    redirection = System.get_redirection!(id)
    {:ok, _redirection} = System.delete_redirection(conn.assigns.current_user, redirection)

    conn
    |> put_flash(:info, gettext("Redirection deleted successfully."))
    |> redirect(to: Routes.admin_redirection_path(conn, :index))
  end

  def allowed?(conn, _, _), do: admin?(conn)
end
