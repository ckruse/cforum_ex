defimpl Cforum.System.AuditingProtocol, for: Cforum.System.Redirection do
  def audit_json(redirection) do
    redirection
    |> Map.from_struct()
    |> Map.drop([:__meta__])
  end
end
