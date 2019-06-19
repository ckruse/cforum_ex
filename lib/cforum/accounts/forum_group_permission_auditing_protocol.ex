defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.ForumGroupPermission do
  def audit_json(permission) do
    permission
    |> Map.from_struct()
    |> Map.drop([:__meta__, :group, :forum])
  end
end
