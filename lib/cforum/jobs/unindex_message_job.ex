defmodule Cforum.Jobs.UnindexMessageJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"message_ids" => mids}}) do
    Cforum.Search.delete_documents_by_reference_ids(mids)
  end

  def enqueue(messages) do
    ids =
      messages
      |> Enum.map(fn
        %Cforum.Messages.Message{} = msg -> msg.message_id
        id -> id
      end)

    %{"message_ids" => ids}
    |> Cforum.Jobs.UnindexMessageJob.new()
    |> Oban.insert!()

    :ok
  end
end
