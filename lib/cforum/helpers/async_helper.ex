defmodule Cforum.Helpers.AsyncHelper do
  def run_async(fun) do
    if Application.get_env(:cforum, :environment) == :test,
      do: fun.(),
      else: Task.start(fun)
  end
end
