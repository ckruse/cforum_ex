defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.Setting do
  def audit_json(setting) do
    setting
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user, :forum])
  end
end
