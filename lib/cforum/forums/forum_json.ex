alias Cforum.Forums.Forum

defimpl Jason.Encoder, for: Forum do
  def encode(forum, options) do
    Jason.Encode.map(
      %{
        forum_id: forum.forum_id,
        slug: forum.slug,
        short_name: forum.short_name,
        name: forum.name,
        description: forum.description,
        keywords: forum.keywords
      },
      options
    )
  end
end
