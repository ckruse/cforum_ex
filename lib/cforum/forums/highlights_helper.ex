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
    highlight_self = ConfigManager.uconf(conn, "highlight_self") == "yes"

    Enum.map(messages, fn msg ->
      msg
      |> apply_suspicious(mark_suspicious)
      |> highlight_self(highlight_self, conn.assigns[:current_user])
    end)
  end

  defp highlight_self(message, false, _), do: message
  defp highlight_self(message, _, nil), do: message

  defp highlight_self(message, _, user) do
    if message.user_id == user.user_id do
      attribs = Map.update!(message.attribs, :classes, &["highlighted-self" | &1])
      %Message{message | attribs: attribs}
    else
      message
    end
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
