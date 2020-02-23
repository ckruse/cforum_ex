defmodule Cforum.Jobs.CiteIndexerJob do
  use Oban.Worker, queue: :background, max_attempts: 5
  import CforumWeb.Gettext

  alias Cforum.ConfigManager
  alias Cforum.Search

  alias Cforum.MarkdownRenderer

  alias CforumWeb.Router.Helpers

  @impl Oban.Worker
  def perform(%{"cite_id" => cite_id}, _) do
    cite_id
    |> Cforum.Cites.get_cite!()
    |> index_cite()

    :ok
  end

  def index_cite(cite) do
    doc = Search.get_document_by_reference_id(cite.cite_id, :cites)
    plain = MarkdownRenderer.to_plain(cite)
    base_relevance = ConfigManager.conf(nil, "search_cites_relevance", :float)

    section =
      "cites"
      |> Search.get_section_by_section_type()
      |> maybe_create_section()

    update_document(section, doc, cite, plain, base_relevance)
  end

  defp maybe_create_section(nil) do
    {:ok, section} = Search.create_section(%{name: gettext("cites"), section_type: "cites", position: -1})
    section
  end

  defp maybe_create_section(sect), do: sect

  defp update_document(section, nil, cite, plain, relevance),
    do: Search.create_document(document_params(section, cite, plain, relevance))

  defp update_document(section, doc, cite, plain, relevance),
    do: Search.update_document(doc, document_params(section, cite, plain, relevance))

  defp document_params(section, cite, plain, relevance) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")

    %{
      author: cite.author,
      user_id: cite.user_id,
      reference_id: cite.cite_id,
      title: gettext("cite %{id}", id: cite.cite_id),
      content: plain,
      search_section_id: section.search_section_id,
      relevance: relevance,
      lang: search_dict,
      document_created: cite.created_at,
      tags: [],
      url: Helpers.cite_url(CforumWeb.Endpoint, :show, cite)
    }
  end

  def enqueue(cite) do
    %{"cite_id" => cite.cite_id}
    |> Cforum.Jobs.CiteIndexerJob.new()
    |> Oban.insert!()
  end
end
