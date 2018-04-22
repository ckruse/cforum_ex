defmodule CforumWeb.CiteController do
  use CforumWeb, :controller

  alias Cforum.Cites
  alias Cforum.Cites.Cite

  def index(conn, params, archived \\ true) do
    count = Cites.count_cites(archived)
    paging = paginate(count, page: params["p"])
    cites = Cites.list_cites(archived, limit: paging.params)

    render(conn, "index.html", cites: cites, paging: paging)
  end

  def index_voting(conn, params), do: index(conn, params, false)

  def new(conn, _params) do
    changeset = Cites.change_cite(%Cite{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"cite" => cite_params}) do
    case Cites.create_cite(cite_params, conn.assigns[:current_user]) do
      {:ok, cite} ->
        conn
        |> put_flash(:info, "Cite created successfully.")
        |> redirect(to: cite_path(conn, :show, cite))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    cite = Cites.get_cite!(id)
    render(conn, "show.html", cite: cite)
  end

  def edit(conn, %{"id" => id}) do
    cite = Cites.get_cite!(id)
    changeset = Cites.change_cite(cite)
    render(conn, "edit.html", cite: cite, changeset: changeset)
  end

  def update(conn, %{"id" => id, "cite" => cite_params}) do
    cite = Cites.get_cite!(id)

    case Cites.update_cite(cite, cite_params) do
      {:ok, cite} ->
        conn
        |> put_flash(:info, "Cite updated successfully.")
        |> redirect(to: cite_path(conn, :show, cite))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", cite: cite, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cite = Cites.get_cite!(id)
    {:ok, _cite} = Cites.delete_cite(cite)

    conn
    |> put_flash(:info, "Cite deleted successfully.")
    |> redirect(to: cite_path(conn, :index))
  end
end
