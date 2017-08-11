defmodule Cforum.Repo do
  use Ecto.Repo, otp_app: :cforum
  import Ecto.Query, warn: false

  def exists?(queryable) do
    query = Ecto.Query.from(x in queryable, select: 1, limit: 1)
    |> Ecto.Queryable.to_query

    case all(query) do
      [1] -> true
      [] -> false
    end
  end
end
