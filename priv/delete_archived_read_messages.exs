alias Cforum.Repo

Repo.query!("""
  DELETE FROM read_messages
  WHERE EXISTS (
    SELECT messages.message_id
    FROM messages
    INNER JOIN threads USING(thread_id)
    WHERE messages.message_id = read_messages.message_id AND threads.archived = true
  )
""")
