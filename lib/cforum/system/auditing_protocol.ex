defprotocol Cforum.System.AuditingProtocol do
  @fallback_to_any true
  def audit_json(object)
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.Tag do
  def audit_json(tag) do
    tag_synonyms = Cforum.Forums.Tags.list_tag_synonyms(tag)
    synonyms = Enum.map(tag_synonyms, &Cforum.System.AuditingProtocol.audit_json(&1))

    tag
    |> Map.from_struct()
    |> Map.drop([:forum, :messages, :__meta__])
    |> Map.put(:synonyms, synonyms)
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.Message do
  def audit_json(message) do
    message = Cforum.Repo.preload(message, [:thread, :tags])

    message
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user, :editor, :forum, :messages, :parent, :votes, :cites, :close_votes])
    |> Map.put(:thread, Cforum.System.AuditingProtocol.audit_json(message.thread))
    |> Map.put(:tags, Cforum.System.AuditingProtocol.audit_json(message.tags))
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.Thread do
  def audit_json(thread) do
    forum =
      case thread.forum do
        %Ecto.Association.NotLoaded{} ->
          Cforum.Forums.get_forum!(thread.forum_id)

        forum ->
          forum
      end
      |> Cforum.System.AuditingProtocol.audit_json()

    thread
    |> Map.from_struct()
    |> Map.drop([:__meta__, :messages, :sorted_messages, :message, :tree])
    |> Map.put(:forum, forum)
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.ModerationQueueEntry do
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
    badges =
      case user.badges do
        %Ecto.Association.NotLoaded{} ->
          []

        badges_list ->
          Enum.map(badges_list, &Cforum.System.AuditingProtocol.audit_json(&1))
      end

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
    |> Map.drop([:badges_users, :users, :__meta__])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.System.Redirection do
  def audit_json(redirection) do
    redirection
    |> Map.from_struct()
    |> Map.drop([:__meta__])
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.TagSynonym do
  def audit_json(synonym) do
    tag =
      case synonym.tag do
        %Ecto.Association.NotLoaded{} -> Cforum.Forums.Tags.get_tag!(synonym.tag_id)
        tag -> tag
      end

    %{"synonym" => synonym.synonym, "tag" => %{"tag_name" => tag.tag_name, "tag_id" => tag.tag_id}}
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.Forum do
  def audit_json(forum) do
    setting =
      case forum.setting do
        %Ecto.Association.NotLoaded{} ->
          Cforum.Accounts.Settings.get_setting_for_forum(forum)

        setting ->
          setting
      end
      |> Cforum.System.AuditingProtocol.audit_json()

    forum
    |> Map.from_struct()
    |> Map.drop([:__meta__, :threads, :messages, :permissions])
    |> Map.put(:setting, setting)
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

defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.CloseVote do
  def audit_json(vote) do
    vote = Cforum.Repo.preload(vote, [:message])

    vote
    |> Map.from_struct()
    |> Map.drop([:__meta__, :voters])
    |> Map.put(:message, Cforum.System.AuditingProtocol.audit_json(vote.message))
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.CloseVoteVoter do
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
