defmodule Cforum.Forums.ForumAuditJson do
  def to_json(forum) do
    forum
    |> Cforum.Repo.preload([:setting])
    |> Map.from_struct()
    |> Map.drop([:__meta__, :threads, :messages, :permissions])
    |> Map.put(:setting, Cforum.System.Auditing.Json.to_json(forum.setting))
  end
end
