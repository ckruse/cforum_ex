defmodule CforumWeb.EventController do
  use CforumWeb, :controller

  alias Cforum.Events

  alias CforumWeb.Sortable
  alias CforumWeb.Paginator

  def index(conn, params) do
    {sort_params, conn} =
      Sortable.sort_collection(conn, [:name, :location, :start_date, :end_date, :visible], dir: :desc)

    count = Events.count_events()
    paging = Paginator.paginate(count, page: params["p"])
    events = Events.list_events(limit: paging.params, order: sort_params, only_visible: true)

    render(conn, "index.html", events: events, page: paging)
  end

  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id, true)
    render(conn, "show.html", event: event)
  end

  def allowed?(_conn, :index, _), do: true
  def allowed?(_conn, :show, _), do: true
  def allowed?(_, _, _), do: false
end
