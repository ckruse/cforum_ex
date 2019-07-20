alias Cforum.Threads.Thread

defimpl Jason.Encoder, for: Thread do
  def encode(thread, options) do
    thread
    |> Map.take([
      :thread_id,
      :archived,
      :deleted,
      :sticky,
      :flags,
      :latest_message,
      :slug,
      :forum_id,
      :created_at,
      :updated_at
    ])
    |> Jason.Encode.map(options)
  end
end
