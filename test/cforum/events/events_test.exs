defmodule Cforum.EventsTest do
  use Cforum.DataCase

  alias Cforum.Events

  describe "events" do
    alias Cforum.Events.Event

    test "list_events/0 returns all events" do
      event = insert(:event)
      events = Events.list_events()
      assert Enum.map(events, & &1.event_id) == [event.event_id]
    end

    test "get_event!/1 returns the event with given id" do
      event = insert(:event)
      new_event = Events.get_event!(event.event_id)
      assert event.event_id == new_event.event_id
    end

    test "create_event/1 with valid data creates a event" do
      params = params_for(:event)
      assert {:ok, %Event{} = event} = Events.create_event(params)
      assert event.name == params[:name]
      assert event.start_date == params[:start_date]
      assert event.end_date == params[:end_date]
      assert event.description == params[:description]
      assert event.location == params[:location]
      assert event.maps_link == params[:maps_link]
      assert event.visible == params[:visible]
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(%{})
    end

    test "update_event/2 with valid data updates the event" do
      event = insert(:event)
      params = params_for(:event)
      assert {:ok, event} = Events.update_event(event, params)
      assert %Event{} = event
      assert event.name == params[:name]
      assert event.start_date == params[:start_date]
      assert event.end_date == params[:end_date]
      assert event.description == params[:description]
      assert event.location == params[:location]
      assert event.maps_link == params[:maps_link]
      assert event.visible == params[:visible]
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = insert(:event)
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, %{name: ""})
      loaded_event = Events.get_event!(event.event_id)
      assert event.event_id == loaded_event.event_id
    end

    test "delete_event/1 deletes the event" do
      event = insert(:event)
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.event_id) end
    end

    test "change_event/1 returns a event changeset" do
      event = insert(:event)
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
