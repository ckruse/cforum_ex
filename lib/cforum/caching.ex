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

  def update(cache, key, fun) do
    Cachex.get_and_update!(cache, key, fn
      nil -> {:ignore, nil}
      val -> fun.(val)
    end)
  end
end
