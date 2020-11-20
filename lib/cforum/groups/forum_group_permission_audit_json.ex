defmodule Cforum.Groups.ForumGroupPermissionAuditJson do
  def to_json(permission) do
    permission
    |> Map.from_struct()
    |> Map.drop([:__meta__, :group, :forum])
  end
end
