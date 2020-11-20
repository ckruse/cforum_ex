defmodule Cforum.Scores.ScoreAuditJson do
  def to_json(score) do
    score
    |> Map.from_struct()
    |> Map.drop([:user, :vote, :message, :__meta__])
  end
end
