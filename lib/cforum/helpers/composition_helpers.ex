defmodule Cforum.Helpers.CompositionHelpers do
  @moduledoc """
  Message (private messages and thread messages) composition helpers
  """

  @doc """
  Returns a quoted version of the given content

  ## Parameters

  - `content` is the content to quote, e.g. the content of the parent message
  - `strip_signature` a boolean to decide whether the signature should
    be dropped or not
  """
  def quote_from_content(content, strip_signature) do
    content
    |> remove_signature(strip_signature)
    |> quote_from_content()
  end

  defp quote_from_content(""), do: ""
  defp quote_from_content(content), do: String.replace(content, ~r/^/m, "> ")

  @doc """
  Adds a greeting to the content when given; when not, it returns the original content

  ## Parameters

  - `content` the content to add the greeting to
  - `greeting` the greeting phrase
  - `name` the name of the person to greet, for the `{$name}` and `{$vname}` placeholders
  - `std_replacement` the standard replacement value for the `{$name}` and `{$vname}` placeholders
  """
  def maybe_add_greeting(content, greeting, name, std_replacement)
  def maybe_add_greeting(content, greeting, _, _) when greeting == nil or greeting == "", do: content
  def maybe_add_greeting(content, greeting, nil, std), do: [name_replacements(greeting, std) | ["\n" | content]]
  def maybe_add_greeting(content, greeting, name, _), do: [name_replacements(greeting, name) | ["\n" | content]]

  defp name_replacements(greeting, name) do
    greeting
    |> String.replace(~r/\{\$name\}/, name)
    |> String.replace(~r/\{\$vname\}/, String.replace(name, ~r/\s.*/, ""))
  end

  @doc """
  Adds a farewell to the content when given; when not, it returns the original content

  ## Parameters

  - `content` the content to add the farewell to
  - `farewell` the farewell phrase
  """
  def maybe_add_farewell(content, farewell) when farewell == nil or farewell == "", do: content
  def maybe_add_farewell(content, farewell), do: [content | ["\n\n" | farewell]]

  @doc """
  Adds a signature (including the signature separator) to the content
  when given; when not, it returns the original content

  ## Parameters

  - `content` the content to add the farewell to
  - `signature` the signature
  """
  def maybe_add_signature(content, signature) when signature == nil or signature == "", do: content
  def maybe_add_signature(content, signature), do: [content | ["\n-- \n" | signature]]

  defp remove_signature(content, false), do: content

  defp remove_signature(content, true) do
    parts =
      content
      |> String.reverse()
      |> String.split(~r/\n --\n/, parts: 2)

    case parts do
      [_, part] ->
        String.reverse(part)

      _ ->
        content
    end
  end

  @doc """
  Helper function for adding a prefix to a subject if not present,
  e.g. prepending a `RE:` if not present

  ## Parameters

  - `subject` the subject to inspect and prepend to
  - `prefix` the prefix to prepend
  """
  def subject_from_parent(subject, prefix) do
    if String.starts_with?(subject, prefix),
      do: subject,
      else: "#{prefix}#{subject}"
  end
end
