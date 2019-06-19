defimpl Cforum.System.AuditingProtocol, for: Cforum.Cites.Cite do
  def audit_json(cite) do
    cite
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user, :creator_user, :message, :votes])
  end
end
