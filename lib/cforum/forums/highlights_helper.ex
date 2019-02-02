defmodule Cforum.Forums.Messages.HighlightsHelper do
  alias Cforum.ConfigManager
  alias Cforum.Forums.{Thread, Message}

  def apply_highlights(threads, conn) do
    Enum.map(threads, fn thread ->
      messages = apply_highlights_to_messages(thread.messages, conn)
      %Thread{thread | messages: messages}
    end)
  end

  def apply_highlights_to_messages(messages, conn) do
    mark_suspicious = ConfigManager.uconf(conn, "mark_suspicious") == "yes"

    Enum.map(messages, fn msg ->
      msg
      |> apply_suspicious(mark_suspicious)
    end)
  end

  defp apply_suspicious(message, false), do: message

  defp apply_suspicious(message, _) do
    String.graphemes(message.author)
    |> Enum.find(fn c ->
      <<v::utf8>> = c
      v < 32 || v > 255
    end)
    |> case do
      nil ->
        message

      _ ->
        attribs = Map.update!(message.attribs, :classes, &["suspicious" | &1])
        %Message{message | attribs: attribs}
    end
  end
end
