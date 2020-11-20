defmodule Cforum.System.Auditing.Json do
  def to_json(obj)

  def to_json(%Cforum.Forums.Forum{} = forum), do: Cforum.Forums.ForumAuditJson.to_json(forum)

  def to_json(%Cforum.Threads.Thread{} = thread), do: Cforum.Threads.ThreadAuditJson.to_json(thread)

  def to_json(%Cforum.Messages.Message{} = msg), do: Cforum.Messages.MessageAuditJson.to_json(msg)
  def to_json(%Cforum.Messages.MessageVersion{} = vsn), do: Cforum.Messages.MessageVersionAuditJson.to_json(vsn)

  def to_json(%Cforum.Badges.Badge{} = badge), do: Cforum.Badges.BadgeAuditJson.to_json(badge)
  def to_json(%Cforum.Badges.BadgeUser{} = badge_user), do: Cforum.Badges.BadgeUserAuditJson.to_json(badge_user)

  def to_json(%Cforum.Cites.Cite{} = cite), do: Cforum.Cites.CiteAuditJson.to_json(cite)

  def to_json(%Cforum.Events.Event{} = event), do: Cforum.Events.EventAuditJson.to_json(event)
  def to_json(%Cforum.Events.Attendee{} = attendee), do: Cforum.Events.AttendeeAuditJson.to_json(attendee)

  def to_json(%Cforum.Groups.ForumGroupPermission{} = group_perm), do: Cforum.Groups.ForumGroupPermissionAuditJson.to_json(group_perm)
  def to_json(%Cforum.Groups.Group{} = group), do: Cforum.Groups.GroupAuditJson.to_json(group)

  def to_json(%Cforum.Media.Image{} = img), do: Cforum.Media.ImageAuditJson.to_json(img)

  def to_json(%Cforum.ModerationQueue.ModerationQueueEntry{} = entry), do: Cforum.ModerationQueue.ModerationQueueEntryAuditJson.to_json(entry)

  def to_json(%Cforum.Scores.Score{} = score), do: Cforum.Scores.ScoreAuditJson.to_json(score)

  def to_json(%Cforum.Settings.Setting{} = setting), do: Cforum.Settings.SettingAuditJson.to_json(setting)

  def to_json(%Cforum.System.Redirection{} = redirection), do: Cforum.System.RedirectionAuditJson.to_json(redirection)

  def to_json(%Cforum.Tags.Tag{} = tag), do: Cforum.Tags.TagAuditJson.to_json(tag)
  def to_json(%Cforum.Tags.Synonym{} = synonym), do: Cforum.Tags.SynonymAuditJson.to_json(synonym)

  def to_json(%Cforum.Users.User{} = usr), do: Cforum.Users.UserAuditJson.to_json(usr)

  def to_json(%Ecto.Association.NotLoaded{}), do: nil
  def to_json(list) when is_list(list), do: Enum.map(list, &to_json/1)
  def to_json(obj), do: obj
end
