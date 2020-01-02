defimpl Jason.Encoder, for: Cforum.Tags.Tag do
  def encode(tag, options) do
    Jason.Encode.map(
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
