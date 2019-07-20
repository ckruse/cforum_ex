defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.Forum do
  def audit_json(forum) do
    forum
    |> Cforum.Repo.preload([:setting])
    |> Map.from_struct()
    |> Map.drop([:__meta__, :threads, :messages, :permissions])
    |> Map.put(:setting, Cforum.System.AuditingProtocol.audit_json(forum.setting))
  end
end
