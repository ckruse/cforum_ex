defmodule Cforum.Jobs.CiteUnindexerJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  alias Cforum.Search

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"cite_id" => cite_id}}) do
    doc = Search.get_document_by_reference_id(cite_id, :cites)

    if !is_nil(doc),
      do: Search.delete_document(doc)

    :ok
  end

  def enqueue(cite) do
    %{"cite_id" => cite.cite_id}
    |> Cforum.Jobs.CiteUnindexerJob.new()
    |> Oban.insert!()
  end
end
