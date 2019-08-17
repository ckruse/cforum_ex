defmodule Cforum.Messages.ReindexMessagesJob do
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Search
  alias Cforum.Search.Document
  alias Cforum.Messages.Message

  def reindex_messages() do
    Repo.transaction(fn ->
      from(doc in Document,
        left_join: msg in Message,
        on: [message_id: doc.reference_id],
        where: not is_nil(doc.forum_id),
        where: is_nil(msg.message_id) or msg.deleted == true
      )
      |> Repo.stream()
      |> Enum.each(&Search.delete_document/1)

      :ok
    end)

    do_reindex_messages()
  end

  defp do_reindex_messages(last_id \\ -1) do
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
