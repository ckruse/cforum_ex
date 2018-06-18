defmodule Cforum.Factory do
  use ExMachina.Ecto, repo: Cforum.Repo
  use Cforum.UserFactory
  use Cforum.NotificationFactory
  use Cforum.PrivMessageFactory
  use Cforum.ScoreFactory
  use Cforum.VoteFactory
  use Cforum.BadgeFactory
  use Cforum.BadgeUserFactory
  use Cforum.ForumFactory
  use Cforum.SettingFactory
  use Cforum.GroupFactory
  use Cforum.ForumGroupPermissionFactory

  use Cforum.ThreadFactory
  use Cforum.MessageFactory
  use Cforum.TagFactory
  use Cforum.ModerationQueueEntryFactory

  use Cforum.CiteFactory

  use Cforum.EventFactory

  use Cforum.RedirectionFactory
end
