defmodule Cforum.Jobs.Appsignal do
  require Logger

  alias Appsignal.Error
  alias Appsignal.Transaction

  def handle_event([:oban, :job, event], measurement, meta, _) when event in [:exception, :stop] do
    transaction = record_event(measurement, meta)

    if event == :exception do
      {reason, message, stack} = normalize_error(meta)
      Logger.error("Error executing job: #{reason} (#{inspect(message)})\n\n#{inspect(stack)}")

      if meta.attempt >= meta.max_attempts,
        do: Transaction.set_error(transaction, reason, message, stack)
    end

    Transaction.complete(transaction)
  end

  defp record_event(measurement, meta) do
    metadata = %{"id" => meta.id, "queue" => meta.queue, "attempt" => meta.attempt}
    transaction = Transaction.start(Transaction.generate_id(), :background_job)

    transaction
    |> Transaction.set_action("#{meta.worker}#perform")
    |> Transaction.set_meta_data(metadata)
    |> Transaction.set_sample_data("params", meta.args)
    |> Transaction.record_event("worker.perform", "", "", measurement.duration, 0)
    |> Transaction.finish()

    transaction
  end

  defp normalize_error(%{kind: kind, error: error, stack: stack}) when kind in [:error, :throw] do
    {reason, message} = Error.metadata(error)
    {inspect(reason), inspect(message), stack}
  end

  defp normalize_error(%{kind: kind, error: error, stack: stack}) do
    {inspect(kind), inspect(error), stack}
  end
end
