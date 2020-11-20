defmodule Cforum.Tags.TagAuditJson do
  def to_json(tag) do
    tag_synonyms = Cforum.Tags.list_tag_synonyms(tag)
    synonyms = Enum.map(tag_synonyms, &Cforum.System.Auditing.Json.to_json/1)

    tag
    |> Map.from_struct()
    |> Map.drop([:forum, :messages, :__meta__])
    |> Map.put(:synonyms, synonyms)
  end
end
