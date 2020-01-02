defimpl Cforum.System.AuditingProtocol, for: Cforum.Tags.Synonym do
  def audit_json(synonym) do
    synonym = Cforum.Repo.preload(synonym, [:tag])

    %{"synonym" => synonym.synonym, "tag" => %{"tag_name" => synonym.tag.tag_name, "tag_id" => synonym.tag.tag_id}}
  end
end
