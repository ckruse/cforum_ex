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
