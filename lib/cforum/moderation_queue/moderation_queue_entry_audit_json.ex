defmodule Cforum.ModerationQueue.ModerationQueueEntryAuditJson do
  def to_json(entry) do
    entry
    |> Map.from_struct()
    |> Map.drop([:__meta__, :message, :closer])
  end
end
