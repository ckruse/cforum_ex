defimpl Poison.Encoder, for: Cforum.Forums.Tag do
  def encode(tag, options) do
    Poison.Encoder.Map.encode(
      %{
        tag_id: tag.tag_id,
        tag_name: tag.tag_name,
        num_messages: tag.num_messages,
        synonyms: Enum.map(tag.synonyms, & &1.synonym)
      },
      options
    )
  end
end
