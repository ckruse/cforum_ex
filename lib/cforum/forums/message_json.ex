alias Cforum.Forums.Message

defimpl Jason.Encoder, for: Message do
  def encode(message, options) do
    Jason.Encode.map(
      %{
        message_id: message.message_id,
        upvotes: message.upvotes,
        downvotes: message.downvotes,
        deleted: message.deleted,
        author: message.author,
        email: message.email,
        homepage: message.homepage,
        subject: message.subject,
        content: message.content,
        flags: message.flags,
        format: message.format,
        edit_author: message.edit_author,
        problematic_site: message.problematic_site,
        attribs: message.attribs,
        thread_id: message.thread_id,
        forum_id: message.forum_id,
        user_id: message.user_id,
        parent_id: message.parent_id,
        editor_id: message.editor_id,
        tags: Enum.map(message.tags, & &1.tag_name),
        created_at: message.created_at,
        updated_at: message.updated_at
      },
      options
    )
  end
end
