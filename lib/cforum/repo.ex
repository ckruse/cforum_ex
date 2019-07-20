defmodule Cforum.Repo do
  use Ecto.Repo, otp_app: :cforum, adapter: Ecto.Adapters.Postgres
  import Ecto.Query, warn: false

  # def exists?(queryable) do
  #   query =
  #     Ecto.Query.from(x in queryable, select: 1, limit: 1)
  #     |> Ecto.Queryable.to_query()

  #   case all(query) do
  #     [1] -> true
  #     [] -> false
  #   end
  # end

  def execute_and_load(sql, params, schema, postprocess \\ nil)

  def execute_and_load(sql, params, schema, nil) do
    result = query!(sql, params)
    Enum.map(result.rows, &load(schema, {result.columns, &1}))
  end

  def execute_and_load(sql, params, schema, postprocess) do
    result = query!(sql, params)

    Enum.map(result.rows, fn row ->
      obj = load(schema, {result.columns, row})

      if postprocess do
        fields = Enum.into(Enum.zip(result.columns, row), %{})
        postprocess.(fields, obj)
      else
        obj
      end
    end)
  end

  def maybe_preload(rel, nil), do: rel
  def maybe_preload(rel, preloads), do: Cforum.Repo.preload(rel, preloads)
end
