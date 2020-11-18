defmodule Cforum.Jobs.Appsignal do
  require Logger

  def handle_event([:oban, :job, :exception], _measurement, meta, _) do
    {kind, reason, stack} = normalize_error(meta)
    Logger.error("Error executing job: #{kind} (#{inspect(reason)})\n\n#{inspect(stack)}")

    if meta.attempt >= meta.max_attempts,
      do: Appsignal.send_error(kind, reason, stack)
  end

  defp normalize_error(%{kind: kind, error: error, stacktrace: stacktrace}) when kind in [:error, :throw],
    do: Appsignal.Error.metadata(kind, error, stacktrace)

  defp normalize_error(%{kind: kind, error: error, stacktrace: stack}),
    do: {inspect(kind), inspect(error), stack}
end
