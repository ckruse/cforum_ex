defmodule Cforum.Cites.CiteAuditJson do
  def to_json(cite) do
    cite
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user, :creator_user, :message, :votes])
  end
end
