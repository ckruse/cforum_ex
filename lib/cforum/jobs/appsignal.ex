defmodule Cforum.Jobs.Appsignal do
  require Logger

  def handle_event([:oban, :job, :exception], _measurement, meta, _) do
    Logger.error("Error executing job: #{meta.kind} (#{inspect(meta.reason)})\n\n#{inspect(meta.stacktrace)}")

    if meta.attempt >= meta.max_attempts,
      do: Appsignal.send_error(meta[:kind], meta[:error], meta[:stacktrace])
  end
end
