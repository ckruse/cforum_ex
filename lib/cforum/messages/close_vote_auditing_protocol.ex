defimpl Cforum.System.AuditingProtocol, for: Cforum.Messages.CloseVote do
  def audit_json(vote) do
    vote = Cforum.Repo.preload(vote, [:message])

    vote
    |> Map.from_struct()
    |> Map.drop([:__meta__, :voters])
    |> Map.put(:message, Cforum.System.AuditingProtocol.audit_json(vote.message))
  end
end
