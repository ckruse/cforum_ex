defmodule Cforum.OrderApi do
  import Ecto.Query, warn: false

  def set_ordering(query, nil, fallback_order), do: set_ordering(query, [], fallback_order)

  def set_ordering(query, [], fallback_order) do
    query
    |> order_by(^fallback_order)
  end

  def set_ordering(query, ordering, fallback_order) do
    query
    |> order_by(^ordering)
    |> order_by(^fallback_order)
  end
end
