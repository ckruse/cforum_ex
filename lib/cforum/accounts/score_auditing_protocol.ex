defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.Score do
  def audit_json(score) do
    score
    |> Map.from_struct()
    |> Map.drop([:user, :vote, :message, :__meta__])
  end
end
