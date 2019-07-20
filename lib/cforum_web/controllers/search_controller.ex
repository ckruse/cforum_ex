defmodule CforumWeb.SearchController do
  use CforumWeb, :controller

  alias Cforum.Search

  alias CforumWeb.Paginator

  def show(conn, %{"search" => search_params} = params) do
    visible_sections = Search.list_visible_search_sections(conn.assigns.visible_forums)
    changeset = Search.search_changeset(visible_sections, search_params)
    count = Search.Finder.count_results(changeset)
    paging = Paginator.paginate(count, page: params["p"])
    results = Search.Finder.search(changeset, paging.params)

    render(conn, "show.html",
      changeset: changeset,
      visible_sections: visible_sections,
      results: results,
      paging: paging,
      params: params
    )
  end

  def show(conn, _params) do
    visible_sections = Search.list_visible_search_sections(conn.assigns.visible_forums)
    changeset = Search.search_changeset(visible_sections)
    render(conn, "show.html", changeset: changeset, visible_sections: visible_sections)
  end

  def allowed?(_, _, _), do: true
end
