defimpl Cforum.System.AuditingProtocol, for: Cforum.Threads.Thread do
  def audit_json(thread) do
    thread = Cforum.Repo.preload(thread, messages: :tags, forum: :setting)
    messages = Enum.map(thread.messages, &Cforum.System.AuditingProtocol.audit_json/1)

    thread
    |> Map.from_struct()
    |> Map.drop([:__meta__, :sorted_messages, :message, :tree])
    |> Map.put(:messages, messages)
    |> Map.put(:forum, Cforum.System.AuditingProtocol.audit_json(thread.forum))
  end
end
