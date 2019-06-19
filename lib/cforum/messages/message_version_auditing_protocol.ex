defimpl Cforum.System.AuditingProtocol, for: Cforum.Messages.MessageVersion do
  def audit_json(version) do
    version = Cforum.Repo.preload(version, message: [thread: :forum])

    version
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user])
    |> Map.put(:message, Cforum.System.AuditingProtocol.audit_json(version.message))
  end
end
