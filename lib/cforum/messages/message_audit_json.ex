defmodule Cforum.Messages.MessageAuditJson do
  @msg_auditing_fields_to_ignore [
    :__meta__,
    :user,
    :editor,
    :forum,
    :messages,
    :parent,
    :votes,
    :cites,
    :versions,
    :messages
  ]

  def to_json(message) do
    message = Cforum.Repo.preload(message, [:thread, :tags])

    message
    |> Map.from_struct()
    |> Map.drop(@msg_auditing_fields_to_ignore)
    |> Map.put(:thread, Cforum.System.Auditing.Json.to_json(maybe_thread(message.thread)))
    |> Map.put(:tags, Cforum.System.Auditing.Json.to_json(message.tags))
  end

  defp maybe_thread(%Ecto.Association.NotLoaded{}), do: nil
  defp maybe_thread(nil), do: nil
  defp maybe_thread(thread), do: %Cforum.Threads.Thread{thread | messages: []}
end
