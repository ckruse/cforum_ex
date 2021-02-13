defmodule Cforum.Caching do
  def fetch(cache, key, fun) do
    case Cachex.exists?(cache, key) do
      {:ok, true} ->
        Cachex.get!(cache, key)

      {:ok, false} ->
        case fun.() do
          {:ok, val} ->
            Cachex.put!(cache, key, val)
            val

          {:error, val} ->
            val

          val ->
            Cachex.put!(cache, key, val)
            val
        end

      {:error, _} ->
        fun.()
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
