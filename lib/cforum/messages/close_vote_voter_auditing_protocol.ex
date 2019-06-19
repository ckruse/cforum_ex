defimpl Cforum.System.AuditingProtocol, for: Cforum.Messages.CloseVoteVoter do
  def audit_json(voter) do
    voter = Cforum.Repo.preload(voter, [:close_vote])

    voter
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user])
    |> Map.put(:close_vote, Cforum.System.AuditingProtocol.audit_json(voter.close_vote))
  end
end
