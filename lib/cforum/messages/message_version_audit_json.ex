defmodule Cforum.Messages.MessageVersionAuditJson do
  def to_json(version) do
    version = Cforum.Repo.preload(version, message: [thread: :forum])

    version
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user])
    |> Map.put(:message, Cforum.System.Auditing.Json.to_json(version.message))
  end
end
