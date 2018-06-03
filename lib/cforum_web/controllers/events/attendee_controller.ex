defmodule CforumWeb.Events.AttendeeController do
  use CforumWeb, :controller

  alias Cforum.Events
  alias Cforum.Events.Attendee

  def new(conn, _params) do
    changeset = Events.change_attendee(%Attendee{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, _params) do
  end

  def load_resource(conn) do
    event = Events.get_event!(conn.params["event_id"])
    Plug.Conn.assign(conn, :event, event)
  end
end
