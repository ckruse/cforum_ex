defmodule Cforum.Cites.ReindexCitesJob do
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Search
  alias Cforum.Search.Document
  alias Cforum.Cites.Cite

  def reindex_cites() do
    Repo.transaction(
      fn ->
        from(doc in Document,
          left_join: cite in Cite,
          on: [cite_id: doc.reference_id],
          inner_join: section in assoc(doc, :search_section),
          where: section.section_type == "cites",
          where: is_nil(cite.cite_id)
        )
        |> Repo.stream()
        |> Enum.each(&Search.delete_document/1)

        :ok
      end,
      timeout: :infinity
    )

    do_reindex_cites()
  end

  defp do_reindex_cites(last_id \\ -1) do
    cite =
      from(cite in Cite,
        where: cite.cite_id > ^last_id,
        where: cite.archived == true,
        order_by: [asc: :cite_id],
        limit: 1
      )
      |> Repo.one()

    if not is_nil(cite) do
      Cforum.Cites.CiteIndexerJob.index_cite_synchronously(cite)
      Process.sleep(100)
      do_reindex_cites(cite.cite_id)
    end
  end
end
