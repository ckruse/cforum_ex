defmodule Cforum.Helpers.CompositionHelpers do
  def quote_from_content(content, strip_signature) do
    content
    |> remove_signature(strip_signature)
    |> quote_from_content()
  end

  def quote_from_content(""), do: ""
  def quote_from_content(content), do: String.replace(content, ~r/^/m, "> ")

  def maybe_add_greeting(content, greeting, _, _) when greeting == nil or greeting == "", do: content
  def maybe_add_greeting(content, greeting, nil, std), do: [name_replacements(greeting, std) | ["\n" | content]]
  def maybe_add_greeting(content, greeting, name, _), do: [name_replacements(greeting, name) | ["\n" | content]]

  defp name_replacements(greeting, name) do
    greeting
    |> String.replace(~r/\{\$name\}/, name)
    |> String.replace(~r/\{\$vname\}/, String.replace(name, ~r/\s.*/, ""))
  end

  def maybe_add_farewell(content, farewell) when farewell == nil or farewell == "", do: content
  def maybe_add_farewell(content, farewell), do: [content | ["\n\n" | farewell]]

  def maybe_add_signature(content, signature) when signature == nil or signature == "", do: content
  def maybe_add_signature(content, signature), do: [content | ["\n-- \n" | signature]]

  defp remove_signature(content, false), do: content

  defp remove_signature(content, true) do
    parts =
      content
      |> String.reverse()
      |> String.split("\n --\n", parts: 2)

    case parts do
      [_, part] ->
        String.reverse(part)

      _ ->
        content
    end
  end

  def subject_from_parent(subject, prefix) do
    if String.starts_with?(subject, prefix),
      do: subject,
      else: "#{prefix}#{subject}"
  end
end
