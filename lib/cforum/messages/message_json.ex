alias Cforum.Messages.Message
alias Cforum.Repo

defimpl Jason.Encoder, for: Message do
  def encode(message, options) do
    message = Repo.preload(message, [:tags])

    message
    |> Map.take([
      :message_id,
      :upvotes,
      :downvotes,
      :deleted,
      :author,
      :email,
      :homepage,
      :subject,
      :content,
      :flags,
      :format,
      :edit_author,
      :problematic_site,
      :attribs,
      :thread_id,
      :forum_id,
      :user_id,
      :parent_id,
      :editor_id,
      :created_at,
      :updated_at
    ])
    |> Map.put(:tags, Enum.map(message.tags, & &1.tag_name))
    |> Jason.Encode.map(options)
  end
end
