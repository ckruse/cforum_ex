defmodule Cforum.OrderApi do
  import Ecto.Query, warn: false

  def set_ordering(query, nil, _), do: query
  def set_ordering(query, [], _), do: query
  def set_ordering(query, ordering, fallback_order) do
    query
    |> order_by(^ordering)
    |> order_by(^fallback_order)
  end
end
