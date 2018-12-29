defmodule Cforum.Factory do
  use ExMachina.Ecto, repo: Cforum.Repo

  def user_factory do
    %Cforum.Accounts.User{
      username: sequence("user-"),
      email: sequence(:email, &"user-#{&1}@example.org"),
      confirmed_at: Timex.now(),
      admin: false,
      active: true,
      activity: 0,
      encrypted_password: "",
      score: 0,
      badges: []
    }
  end

  def as_admin(user), do: %{user | admin: true}
  def with_password(user, pass), do: %{user | encrypted_password: Comeonin.Bcrypt.hashpwsalt(pass)}

  def with_badge(user, badge) do
    insert(:badge_user, user: user, badge: badge)
    Cforum.Repo.preload(user, badges_users: :badge)
  end

  def notification_factory do
    %Cforum.Accounts.Notification{
      is_read: false,
      subject: Faker.Lorem.sentence(%Range{first: 1, last: 10}),
      path: "/foo/bar",
      oid: 0,
      otype: "none",
      recipient: build(:user)
    }
  end

  def priv_message_factory do
    %Cforum.Accounts.PrivMessage{
      owner: build(:user),
      is_read: false,
      subject: sequence("Subject "),
      body: Faker.Lorem.paragraph(%Range{first: 1, last: 3}),
      sender_name: Faker.Name.name(),
      recipient_name: Faker.Name.name()
    }
  end

  def score_factory, do: %Cforum.Accounts.Score{value: 10, user: build(:user)}
  def with_negative_score(score), do: %{score | value: -10}
  def with_message(score), do: %{score | message: build(:message)}
  def with_vote(score), do: %{score | vote: build(:vote)}

  def vote_factory do
    %Cforum.Forums.Vote{
      vtype: Cforum.Forums.Vote.upvote(),
      user: build(:user),
      message: build(:message),
      score: build(:score)
    }
  end

  def badge_factory do
    %Cforum.Accounts.Badge{
      name: sequence("Badge "),
      slug: sequence("slug-"),
      badge_medal_type: "bronze",
      badge_type: "custom",
      order: 0
    }
  end

  def badge_user_factory, do: %Cforum.Accounts.BadgeUser{badge: build(:badge), user: build(:user)}

  def forum_factory do
    %Cforum.Forums.Forum{
      name: sequence("Forum "),
      short_name: sequence("Forum "),
      slug: sequence("forum-"),
      description: Faker.Lorem.sentence(%Range{first: 1, last: 3}),
      standard_permission: "private",
      position: 0
    }
  end

  def public_forum_factory, do: build(:forum, standard_permission: "write")

  def setting_factory, do: %Cforum.Accounts.Setting{options: %{}}
  def setting_with_user(setting), do: %Cforum.Accounts.Setting{setting | user: build(:user)}
  def setting_with_forum(setting), do: %Cforum.Accounts.Setting{setting | forum: build(:forum)}

  def group_factory, do: %Cforum.Accounts.Group{name: sequence("Group ")}

  def forum_group_permission_factory,
    do: %Cforum.Accounts.ForumGroupPermission{permission: "read", forum: build(:forum), group: build(:group)}

  def thread_factory do
    %Cforum.Forums.Thread{
      slug: sequence("/1999/mar/1/lulu"),
      forum: build(:forum),
      latest_message: Timex.now()
    }
  end

  def message_factory do
    %Cforum.Forums.Message{
      author: Faker.Name.name(),
      subject: Faker.Lorem.sentence(%Range{first: 1, last: 10}),
      content: Faker.Lorem.paragraph(%Range{first: 1, last: 2})
    }
  end

  def tag_factory do
    %Cforum.Forums.Tag{
      tag_name: sequence("Tag "),
      slug: sequence("tag-"),
      suggest: true
    }
  end

  def tag_synonym_factory do
    %Cforum.Forums.TagSynonym{
      tag: build(:tag),
      synonym: sequence("Tag Synonym ")
    }
  end

  def close_vote_factory do
    %Cforum.Forums.CloseVote{
      reason: "spam",
      vote_type: false,
      finished: false,
      message: build(:message)
    }
  end

  def moderation_queue_entry_factory do
    %Cforum.Forums.ModerationQueueEntry{
      cleared: false,
      reported: 1,
      reason: "off-topic"
    }
  end

  def closed_moderation_queue_entry_factory do
    %Cforum.Forums.ModerationQueueEntry{
      cleared: true,
      reported: 1,
      reason: "off-topic",
      closer_name: sequence("Closer "),
      closer_id: build(:user),
      resolution_action: "delete",
      resolution: "Delete this shit!"
    }
  end

  def cite_factory do
    %Cforum.Cites.Cite{
      archived: false,
      author: sequence("Author "),
      cite: Faker.Lorem.sentence(%Range{first: 1, last: 10}),
      cite_date: Timex.now(),
      creator: sequence("Creator "),
      url: sequence("https://example.com/cites/")
    }
  end

  def archived_cite(cite), do: %Cforum.Cites.Cite{cite | archived: true}

  def cite_vote_factory do
    %Cforum.Cites.Vote{
      vote_type: Cforum.Cites.Vote.upvote(),
      user: build(:user),
      cite: build(:cite)
    }
  end

  def event_factory do
    %Cforum.Events.Event{
      name: sequence("Event "),
      start_date: Timex.today(),
      end_date: Timex.today() |> Timex.shift(days: 2),
      location: sequence("Location "),
      description: Faker.Lorem.paragraph(%Range{first: 1, last: 2}),
      visible: false
    }
  end

  def attendee_factory do
    %Cforum.Events.Attendee{
      name: sequence("Attendee "),
      planned_arrival: Timex.now(),
      event: build(:event)
    }
  end

  def redirection_factory do
    %Cforum.System.Redirection{
      path: sequence("/foo"),
      destination: sequence("/bar"),
      http_status: 301
    }
  end

  def search_section_factory do
    %Cforum.Search.Section{
      active_by_default: false,
      name: sequence("Section "),
      position: sequence(:position, & &1),
      section_type: "cites"
    }
  end

  def search_document_factory do
    %Cforum.Search.Document{
      author: sequence("Author "),
      content: Faker.Lorem.paragraph(%Range{first: 1, last: 2}),
      document_created: DateTime.truncate(Timex.now(), :second),
      lang: "german",
      relevance: 1.0,
      tags: [],
      title: Faker.Lorem.sentence(%Range{first: 1, last: 10}),
      url: sequence("https://example.org/search-"),
      search_section: build(:search_section)
    }
  end
end
