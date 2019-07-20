defimpl Cforum.System.AuditingProtocol, for: Cforum.Events.Event do
  def audit_json(event) do
    event
    |> Map.from_struct()
    |> Map.drop([:attendees, :__meta__])
  end
end
