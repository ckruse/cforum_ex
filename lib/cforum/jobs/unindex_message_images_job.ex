defmodule Cforum.Jobs.UnindexMessageImagesJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  alias Cforum.Repo
  alias Cforum.Messages

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"message_id" => message_id}}) do
    Messages.get_message!(message_id, view_all: true, with: [:images])
    |> Ecto.Changeset.change(%{})
    |> Ecto.Changeset.put_assoc(:images, [])
    |> Repo.update()

    :ok
  end

  def enqueue(message_ids) when is_list(message_ids) do
    Enum.each(message_ids, fn id ->
      %{"message_id" => id}
      |> Cforum.Jobs.UnindexMessageImagesJob.new()
      |> Oban.insert!()
    end)
  end

  def enqueue(message) do
    %{"message_id" => message.message_id}
    |> Cforum.Jobs.UnindexMessageImagesJob.new()
    |> Oban.insert!()
  end
end
