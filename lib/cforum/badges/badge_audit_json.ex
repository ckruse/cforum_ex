defmodule Cforum.Badges.BadgeAuditJson do
  def to_json(badge) do
    badge
    |> Map.from_struct()
    |> Map.drop([:badges_users, :users, :__meta__, :badges])
  end
end
