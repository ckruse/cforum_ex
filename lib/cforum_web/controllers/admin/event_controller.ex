defmodule CforumWeb.Admin.EventController do
  use CforumWeb, :controller

  alias Cforum.Events
  alias Cforum.Events.Event

  alias CforumWeb.Sortable
  alias CforumWeb.Paginator

  def index(conn, params) do
    {sort_params, conn} =
      Sortable.sort_collection(conn, [:name, :location, :start_date, :end_date, :visible], dir: :desc)

    count = Events.count_events()
    paging = Paginator.paginate(count, page: params["p"])
    events = Events.list_events(limit: paging.params, order: sort_params)

    render(conn, "index.html", events: events, page: paging)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    case Events.create_event(conn.assigns.current_user, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, gettext("Event created successfully."))
        |> redirect(to: Routes.admin_event_path(conn, :edit, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Events.get_event!(id)

    case Events.update_event(conn.assigns.current_user, event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, gettext("Event updated successfully."))
        |> redirect(to: Routes.admin_event_path(conn, :edit, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    {:ok, _event} = Events.delete_event(conn.assigns.current_user, event)

    conn
    |> put_flash(:info, gettext("Event deleted successfully."))
    |> redirect(to: Routes.admin_event_path(conn, :index))
  end

  def allowed?(conn, _, _), do: Abilities.admin?(conn)
end
