defmodule Cforum.Jobs.RescoreMessageJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  @impl Oban.Worker
  def perform(%{"message_ids" => mids}, _) do
    Enum.each(mids, fn mid ->
      msg = Cforum.Messages.get_message!(mid)
      doc = Cforum.Search.get_document_by_reference_id(msg.message_id)

      if !is_nil(doc) do
        forum = Cforum.Forums.get_forum!(msg.forum_id)
        base_relevance = Cforum.ConfigManager.conf(forum, "search_forum_relevance", :float)
        relevance = Cforum.Jobs.MessageIndexerJob.message_relevance(base_relevance, msg)
        Cforum.Search.update_document(doc, %{relevance: relevance})
      end
    end)
  end

  def enqueue(messages) when is_list(messages) do
    ids =
      messages
      |> Enum.map(fn
        %Cforum.Messages.Message{} = msg -> msg.message_id
        id -> id
      end)

    %{"message_ids" => ids}
    |> Cforum.Jobs.RescoreMessageJob.new()
    |> Oban.insert!()

    :ok
  end

  def enqueue(message) do
    %{"message_ids" => [message.message_id]}
    |> Cforum.Jobs.RescoreMessageJob.new()
    |> Oban.insert!()
  end
end
