defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.BadgeUser do
  def audit_json(badge_user) do
    badge_user = Cforum.Repo.preload(badge_user, [:badge, :user])
    Cforum.System.AuditingProtocol.audit_json(badge_user.badge)
  end
end
