defmodule CforumWeb.Api.V1.EventController do
  use CforumWeb, :controller

  alias Cforum.Events

  def show(conn, _params) do
    render(conn, "show.json")
  end

  def load_resource(conn) do
    event = Events.get_event!(conn.params["id"])
    Plug.Conn.assign(conn, :event, event)
  end

  def allowed?(_, _, _), do: true
end
