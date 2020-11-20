defmodule Cforum.Groups.GroupAuditJson do
  def to_json(group) do
    group
    |> Map.from_struct()
    |> Map.drop([:__meta__, :users, :permissions])
  end
end
