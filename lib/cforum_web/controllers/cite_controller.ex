defmodule CforumWeb.CiteController do
  use CforumWeb, :controller

  alias Cforum.Cites
  alias Cforum.Cites.Cite

  alias CforumWeb.Paginator

  def index(conn, params, archived \\ true) do
    count = Cites.count_cites(archived)
    paging = Paginator.paginate(count, page: params["p"])
    cites = Cites.list_cites(archived, limit: paging.params)

    render(conn, "index.html", cites: cites, paging: paging)
  end

  def index_voting(conn, params), do: index(conn, params, false)

  def new(conn, _params) do
    changeset = Cites.change_cite(%Cite{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"cite" => cite_params}) do
    case Cites.create_cite(conn.assigns[:current_user], cite_params) do
      {:ok, cite} ->
        conn
        |> put_flash(:info, gettext("Cite created successfully."))
        |> redirect(to: Path.cite_path(conn, :show, cite))

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

    case Cites.update_cite(conn.assigns.current_user, cite, cite_params) do
      {:ok, cite} ->
        conn
        |> put_flash(:info, gettext("Cite updated successfully."))
        |> redirect(to: Path.cite_path(conn, :show, cite))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", cite: cite, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cite = Cites.get_cite!(id)
    {:ok, _cite} = Cites.delete_cite(conn.assigns.current_user, cite)

    conn
    |> put_flash(:info, gettext("Cite deleted successfully."))
    |> redirect(to: Path.cite_path(conn, :index))
  end

  def allowed?(_conn, action, _) when action in [:index, :show, :new, :create], do: true
  def allowed?(conn, :index_voting, _), do: Abilities.signed_in?(conn)
  def allowed?(conn, action, _) when action not in [:index, :show, :new, :create], do: Abilities.admin?(conn)
  def allowed?(_, _, _), do: false
end
