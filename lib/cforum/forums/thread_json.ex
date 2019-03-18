alias Cforum.Forums.Thread

defimpl Jason.Encoder, for: Thread do
  def encode(thread, options) do
    Jason.Encode.map(
      %{
        thread_id: thread.thread_id,
        archived: thread.archived,
        deleted: thread.deleted,
        sticky: thread.sticky,
        flags: thread.flags,
        latest_message: thread.latest_message,
        slug: thread.slug,
        forum_id: thread.forum_id,
        created_at: thread.created_at,
        updated_at: thread.updated_at
      },
      options
    )
  end
end
