defimpl Cforum.System.AuditingProtocol, for: Cforum.ModerationQueue.ModerationQueueEntry do
  def audit_json(entry) do
    entry
    |> Map.from_struct()
    |> Map.drop([:__meta__, :message, :closer])
  end
end
