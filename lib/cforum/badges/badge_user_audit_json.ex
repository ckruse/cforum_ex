defmodule Cforum.Badges.BadgeUserAuditJson do
  def to_json(badge_user) do
    badge_user = Cforum.Repo.preload(badge_user, [:badge, :user])
    Cforum.System.Auditing.Json.to_json(badge_user.badge)
  end
end
