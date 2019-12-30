defimpl Cforum.System.AuditingProtocol, for: Cforum.Groups.Group do
  def audit_json(group) do
    group
    |> Map.from_struct()
    |> Map.drop([:__meta__, :users, :permissions])
  end
end
