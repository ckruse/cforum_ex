defmodule Cforum.PagingApi do
  import Ecto.Query, warn: false

  def set_limit(query, nil), do: query
  def set_limit(query, []), do: query
  def set_limit(query, limit) do
    query
    |> limit(^limit[:quantity])
    |> offset(^limit[:offset])
  end
end
