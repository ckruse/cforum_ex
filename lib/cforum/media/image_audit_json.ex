defmodule Cforum.Media.ImageAuditJson do
  def to_json(img) do
    img
    |> Map.from_struct()
    |> Map.drop([:__meta__, :owner, :messages])
  end
end
