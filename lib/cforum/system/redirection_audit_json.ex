defmodule Cforum.System.RedirectionAuditJson do
  def to_json(redirection) do
    redirection
    |> Map.from_struct()
    |> Map.drop([:__meta__])
  end
end
