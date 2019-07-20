defimpl Cforum.System.AuditingProtocol, for: Cforum.Events.Attendee do
  def audit_json(attendee) do
    attendee
    |> Map.from_struct()
    |> Map.drop([:__meta__, :event, :user])
  end
end
