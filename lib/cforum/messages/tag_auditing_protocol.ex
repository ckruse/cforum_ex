defimpl Cforum.System.AuditingProtocol, for: Cforum.Messages.Tag do
  def audit_json(tag) do
    tag_synonyms = Cforum.Messages.Tags.list_tag_synonyms(tag)
    synonyms = Enum.map(tag_synonyms, &Cforum.System.AuditingProtocol.audit_json(&1))

    tag
    |> Map.from_struct()
    |> Map.drop([:forum, :messages, :__meta__])
    |> Map.put(:synonyms, synonyms)
  end
end
