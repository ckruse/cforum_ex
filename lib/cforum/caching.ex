defmodule Cforum.Caching do
  def fetch(cache, key, fun) do
    case Cachex.exists?(cache, key) do
      {:ok, true} ->
        Cachex.get!(cache, key)

      {:ok, false} ->
        val = fun.()
        Cachex.put!(cache, key, val)
        val

      {:error, _} = v ->
        throw(v)
    end
  end

  def del(cache, key) do
    Cachex.del!(cache, key)
  end
end
