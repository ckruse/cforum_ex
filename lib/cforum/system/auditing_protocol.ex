defprotocol Cforum.System.AuditingProtocol do
  @fallback_to_any true
  def audit_json(object)
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Messages.Tag do
  def audit_json(tag) do
    tag_synonyms = Cforum.Messages.Tags.list_tag_synonyms(tag)
    synonyms = Enum.map(tag_synonyms, &Cforum.System.AuditingProtocol.audit_json(&1))

    tag
    |> Map.from_struct()
    |> Map.drop([:forum, :messages, :__meta__])
    |> Map.put(:synonyms, synonyms)
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Messages.Message do
  @msg_auditing_fields_to_ignore [
    :__meta__,
    :user,
    :editor,
    :forum,
    :messages,
    :parent,
    :votes,
    :cites,
    :close_votes,
    :versions,
    :references,
    :messages
  ]

  def audit_json(message) do
    message = Cforum.Repo.preload(message, [:thread, :tags])

    message
    |> Map.from_struct()
    |> Map.drop(@msg_auditing_fields_to_ignore)
    |> Map.put(:thread, Cforum.System.AuditingProtocol.audit_json(maybe_thread(message.thread)))
    |> Map.put(:tags, Cforum.System.AuditingProtocol.audit_json(message.tags))
  end

  defp maybe_thread(%Ecto.Association.NotLoaded{}), do: nil
  defp maybe_thread(nil), do: nil
  defp maybe_thread(thread), do: %Cforum.Threads.Thread{thread | messages: []}
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Threads.Thread do
  def audit_json(thread) do
    thread = Cforum.Repo.preload(thread, messages: :tags, forum: :setting)
    messages = Enum.map(thread.messages, &Cforum.System.AuditingProtocol.audit_json/1)

    thread
    |> Map.from_struct()
    |> Map.drop([:__meta__, :sorted_messages, :message, :tree])
    |> Map.put(:messages, messages)
    |> Map.put(:forum, Cforum.System.AuditingProtocol.audit_json(thread.forum))
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Messages.MessageVersion do
  def audit_json(version) do
    version = Cforum.Repo.preload(version, message: [thread: :forum])

    version
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user])
    |> Map.put(:message, Cforum.System.AuditingProtocol.audit_json(version.message))
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.ModerationQueue.ModerationQueueEntry do
  def audit_json(entry) do
    entry
    |> Map.from_struct()
    |> Map.drop([:__meta__, :message, :closer])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.Score do
  def audit_json(score) do
    score
    |> Map.from_struct()
    |> Map.drop([:user, :vote, :message, :__meta__])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.ForumGroupPermission do
  def audit_json(permission) do
    permission
    |> Map.from_struct()
    |> Map.drop([:__meta__, :group, :forum])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.Group do
  def audit_json(group) do
    group
    |> Map.from_struct()
    |> Map.drop([:__meta__, :users, :permissions])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.User do
  def audit_json(user) do
    user = Cforum.Repo.preload(user, [:badges])
    badges = Enum.map(user.badges, &Cforum.System.AuditingProtocol.audit_json/1)

    user
    |> Map.from_struct()
    |> Map.drop([
      :encrypted_password,
      :authentication_token,
      :email,
      :settings,
      :badges_users,
      :groups,
      :cites,
      :__meta__
    ])
    |> Map.put(:badges, badges)
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.Setting do
  def audit_json(setting) do
    setting
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user, :forum])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.Badge do
  def audit_json(badge) do
    badge
    |> Map.from_struct()
    |> Map.drop([:badges_users, :users, :__meta__, :badges])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.BadgeUser do
  def audit_json(badge_user) do
    badge_user = Cforum.Repo.preload(badge_user, [:badge, :user])
    Cforum.System.AuditingProtocol.audit_json(badge_user.badge)
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.System.Redirection do
  def audit_json(redirection) do
    redirection
    |> Map.from_struct()
    |> Map.drop([:__meta__])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Messages.TagSynonym do
  def audit_json(synonym) do
    synonym = Cforum.Repo.preload(synonym, [:tag])

    %{"synonym" => synonym.synonym, "tag" => %{"tag_name" => synonym.tag.tag_name, "tag_id" => synonym.tag.tag_id}}
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.Forum do
  def audit_json(forum) do
    forum
    |> Cforum.Repo.preload([:setting])
    |> Map.from_struct()
    |> Map.drop([:__meta__, :threads, :messages, :permissions])
    |> Map.put(:setting, Cforum.System.AuditingProtocol.audit_json(forum.setting))
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Events.Event do
  def audit_json(event) do
    event
    |> Map.from_struct()
    |> Map.drop([:attendees, :__meta__])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Events.Attendee do
  def audit_json(attendee) do
    attendee
    |> Map.from_struct()
    |> Map.drop([:__meta__, :event, :user])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Cites.Cite do
  def audit_json(cite) do
    cite
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user, :creator_user, :message, :votes])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Messages.CloseVote do
  def audit_json(vote) do
    vote = Cforum.Repo.preload(vote, [:message])

    vote
    |> Map.from_struct()
    |> Map.drop([:__meta__, :voters])
    |> Map.put(:message, Cforum.System.AuditingProtocol.audit_json(vote.message))
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Messages.CloseVoteVoter do
  def audit_json(voter) do
    voter = Cforum.Repo.preload(voter, [:close_vote])

    voter
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user])
    |> Map.put(:close_vote, Cforum.System.AuditingProtocol.audit_json(voter.close_vote))
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Media.Image do
  def audit_json(img) do
    img
    |> Map.from_struct()
    |> Map.drop([:__meta__, :owner])
  end
end

defimpl Cforum.System.AuditingProtocol, for: List do
  def audit_json(list), do: Enum.map(list, &Cforum.System.AuditingProtocol.audit_json(&1))
end

defimpl Cforum.System.AuditingProtocol, for: Any do
  def audit_json(object), do: object
end
