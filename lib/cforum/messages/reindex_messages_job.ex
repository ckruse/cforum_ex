defmodule Cforum.Messages.ReindexMessagesJob do
  use Appsignal.Instrumentation.Decorators
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Search
  alias Cforum.Search.Document
  alias Cforum.Messages.Message

  @decorate transaction(:indexing)
  def reindex_messages(start_id \\ 0) do
    Repo.transaction(
      fn ->
        from(doc in Document,
          left_join: msg in Message,
          on: [message_id: doc.reference_id],
          inner_join: section in assoc(doc, :search_section),
          where: section.section_type == "forum",
          where: is_nil(msg.message_id) or msg.deleted == true
        )
        |> Repo.stream()
        |> Enum.each(&Search.delete_document/1)

        :ok
      end,
      timeout: :infinity
    )

    do_reindex_messages(start_id - 1)
  end

  @decorate transaction_event(:indexing)
  defp do_reindex_messages(last_id) do
    mid =
      from(m in Message,
        select: m.message_id,
        where: m.message_id > ^last_id,
        where: m.deleted == false,
        order_by: [asc: :message_id],
        limit: 1
      )
      |> Repo.one()

    if not is_nil(mid) do
      Cforum.Messages.MessageIndexerJob.index_message_synchronously(mid)
      Process.sleep(100)
      do_reindex_messages(mid)
    end
  end
end
