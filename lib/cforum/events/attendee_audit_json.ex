defmodule Cforum.Events.AttendeeAuditJson do
  def to_json(attendee) do
    attendee
    |> Map.from_struct()
    |> Map.drop([:__meta__, :event, :user])
  end
end
