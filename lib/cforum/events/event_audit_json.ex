defmodule Cforum.Events.EventAuditJson do
  def to_json(event) do
    event
    |> Map.from_struct()
    |> Map.drop([:attendees, :__meta__])
  end
end
