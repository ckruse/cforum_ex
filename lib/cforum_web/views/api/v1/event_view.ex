defmodule CforumWeb.Api.V1.EventView do
  use CforumWeb, :view

  alias CforumWeb.Api.V1.EventView

  def render("show.json", %{event: event}) do
    render_one(event, EventView, "event.json")
  end

  def render("event.json", %{event: event}) do
    %{
      event_id: event.event_id,
      name: event.name,
      description: event.description,
      start_date: event.start_date,
      end_date: event.end_date,
      location: event.location
    }
  end
end
