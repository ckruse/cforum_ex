defmodule Cforum.Messages.HighlightsHelper do
  alias Cforum.ConfigManager
  alias Cforum.Threads.Thread
  alias Cforum.Messages.Message

  def apply_highlights(threads, conn) do
    Enum.map(threads, fn thread ->
      messages = apply_highlights_to_messages(thread.messages, conn)
      %Thread{thread | messages: messages}
    end)
  end

  defp parse_userlist(nil), do: nil
  defp parse_userlist(""), do: nil

  defp parse_userlist(list) do
    list
    |> String.split(~r/\s*,\s*/)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.downcase/1)
    |> Enum.reduce(%{}, fn nam, acc -> Map.put(acc, nam, true) end)
  end

  def apply_highlights_to_messages(messages, conn) do
    mark_suspicious = ConfigManager.uconf(conn, "mark_suspicious") == "yes"
    highlight_self = ConfigManager.uconf(conn, "highlight_self") == "yes"
    highlight_users = parse_userlist(ConfigManager.uconf(conn, "highlighted_users"))

    Enum.map(messages, fn msg ->
      msg
      |> apply_suspicious(mark_suspicious)
      |> apply_highlight_self(highlight_self, conn.assigns[:current_user])
      |> apply_highlight_users(highlight_users)
    end)
  end

  defp apply_highlight_users(message, nil), do: message

  defp apply_highlight_users(message, users) do
    author =
      message.author
      |> String.trim()
      |> String.downcase()

    if Map.has_key?(users, author) do
      attribs = Map.update!(message.attribs, :classes, &["highlighted-user" | &1])
      %Message{message | attribs: attribs}
    else
      message
    end
  end

  defp apply_highlight_self(message, false, _), do: message
  defp apply_highlight_self(message, _, nil), do: message

  defp apply_highlight_self(message, _, user) do
    if message.user_id == user.user_id do
      attribs = Map.update!(message.attribs, :classes, &["highlighted-self" | &1])
      %Message{message | attribs: attribs}
    else
      message
    end
  end

  defp suspicious?(str) do
    str
    |> String.graphemes()
    |> Enum.find(fn c ->
      <<v::utf8>> = c
      v < 32 || v > 255
    end) != nil
  rescue
    _ -> true
  end

  defp apply_suspicious(message, false), do: message

  defp apply_suspicious(message, _) do
    case suspicious?(message.author) do
      false ->
        message

      _ ->
        attribs = Map.update!(message.attribs, :classes, &["suspicious" | &1])
        %Message{message | attribs: attribs}
    end
  end

  def highlights_for_username(config, user, username) do
    highlight_users = parse_userlist(ConfigManager.uconf(config, "highlighted_users"))

    []
    |> maybe_apply_suspicious(ConfigManager.uconf(config, "mark_suspicious") == "yes", username)
    |> maybe_apply_highlight_self(ConfigManager.uconf(config, "highlight_self") == "yes", user, username)
    |> maybe_apply_highlighted_user(highlight_users, username)
  end

  defp maybe_apply_suspicious(classes, false, _), do: classes

  defp maybe_apply_suspicious(classes, _, username) do
    if suspicious?(username),
      do: ["suspicious" | classes],
      else: classes
  end

  defp maybe_apply_highlight_self(classes, false, _, _), do: classes
  defp maybe_apply_highlight_self(classes, _, nil, _), do: classes

  defp maybe_apply_highlight_self(classes, _, user, username) do
    if user.username == username,
      do: ["highlighted-self" | classes],
      else: classes
  end

  defp maybe_apply_highlighted_user(classes, nil, _), do: classes

  defp maybe_apply_highlighted_user(classes, users, username) do
    normalized_username =
      username
      |> String.trim()
      |> String.downcase()

    if Map.has_key?(users, normalized_username),
      do: ["highlighted-user" | classes],
      else: classes
  end
end
