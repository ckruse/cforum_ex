defmodule CforumWeb.Admin.SearchSectionController do
  use CforumWeb, :controller

  alias Cforum.Search
  alias Cforum.Search.Section
  alias Cforum.Forums

  def index(conn, _params) do
    search_sections = Search.list_search_sections()
    render(conn, "index.html", search_sections: search_sections)
  end

  def new(conn, _params) do
    changeset = Search.change_section(%Section{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"section" => section_params}) do
    case Search.create_section(section_params) do
      {:ok, section} ->
        conn
        |> put_flash(:info, gettext("Search section created successfully."))
        |> redirect(to: admin_search_section_path(conn, :edit, section))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    section = Search.get_section!(id)
    changeset = Search.change_section(section)
    render(conn, "edit.html", section: section, changeset: changeset)
  end

  def update(conn, %{"id" => id, "section" => section_params}) do
    section = Search.get_section!(id)

    case Search.update_section(section, section_params) do
      {:ok, section} ->
        conn
        |> put_flash(:info, gettext("Search section updated successfully."))
        |> redirect(to: admin_search_section_path(conn, :edit, section))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", section: section, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    section = Search.get_section!(id)
    {:ok, _section} = Search.delete_section(section)

    conn
    |> put_flash(:info, gettext("Search section deleted successfully."))
    |> redirect(to: admin_search_section_path(conn, :index))
  end

  def load_resource(conn) do
    section = if present?(conn.params["id"]), do: Search.get_section!(conn.params["id"]), else: nil
    forums = if action_name(conn) in [:new, :create, :edit, :update], do: Forums.list_forums(), else: []

    conn
    |> Plug.Conn.assign(:section, section)
    |> Plug.Conn.assign(:forums, forums)
  end

  def allowed?(conn, _, _), do: admin?(conn)
end
