defmodule Cforum.Search.Query do
  @moduledoc """
  TODO write documentation
  """

  defstruct author: %{include: [], exclude: []},
            title: %{include: [], exclude: []},
            content: %{include: [], exclude: []},
            tags: %{include: [], exclude: []},
            all: %{include: [], exclude: []}

  alias Cforum.Search.Query

  @typep section :: :author | :title | :content | :tags | :all
  @typep term_type :: :include | :exclude | nil

  @spec parse(String.t()) :: %Query{}
  def parse(search_string) do
    {nil, query} = parse_search_terms(skip_whitespaces(search_string))
    query
  end

  @spec parse_search_terms(String.t() | nil, %Query{}, section(), term_type()) :: {String.t() | nil, %Query{}}
  defp parse_search_terms(search_string, query \\ %Query{}, current \\ :all, current_type \\ nil)
  defp parse_search_terms("", query, _current, _current_type), do: {nil, query}
  defp parse_search_terms(nil, query, _current, _current_type), do: {nil, query}

  defp parse_search_terms("-" <> rest, query, current, _), do: parse_search_terms(rest, query, current, :exclude)
  defp parse_search_terms("+" <> rest, query, current, _), do: parse_search_terms(rest, query, current, :include)

  defp parse_search_terms("author:" <> rest, query, current, current_type),
    do: continue_parse_search_terms(rest, query, :author, current_type, current)

  defp parse_search_terms("title:" <> rest, query, current, current_type),
    do: continue_parse_search_terms(rest, query, :title, current_type, current)

  defp parse_search_terms("body:" <> rest, query, current, current_type),
    do: continue_parse_search_terms(rest, query, :content, current_type, current)

  defp parse_search_terms("tag:" <> rest, query, current, current_type),
    do: continue_parse_search_terms(rest, query, :tags, current_type, current)

  defp parse_search_terms("\"" <> rest, query, current, current_type) do
    {rest, str} = read_string(rest)
    parse_search_terms(skip_whitespaces(rest), set_search_term(query, str, current, current_type), :all)
  end

  defp parse_search_terms(str, query, current, current_type) do
    case Regex.run(~r/^(\S+)/, str) do
      [_, word] ->
        rest = Regex.replace(~r/^(\S+)/, str, "", global: false)
        parse_search_terms(skip_whitespaces(rest), set_search_term(query, word, current, current_type), :all)

      _ ->
        {nil, query}
    end
  end

  @spec continue_parse_search_terms(String.t() | nil, %Query{}, section(), term_type(), section()) ::
          {String.t() | nil, %Query{}}
  defp continue_parse_search_terms(rest, query, current_section, current_type, last_section) do
    {rest, query} = parse_search_terms(skip_whitespaces(rest), query, current_section, current_type)

    if is_nil(rest),
      do: {nil, query},
      else: parse_search_terms(skip_whitespaces(rest), query, last_section)
  end

  @spec skip_whitespaces(String.t()) :: String.t()
  defp skip_whitespaces(str), do: Regex.replace(~r/^\s+/, str, "")

  @spec read_string(String.t(), iodata()) :: {String.t(), String.t()}
  defp read_string(str, acc \\ "")
  defp read_string("\"" <> str, acc), do: {str, IO.iodata_to_binary(acc)}
  defp read_string("\\\"" <> str, acc), do: read_string(str, [acc, "\""])
  defp read_string("", acc), do: {"", IO.iodata_to_binary(acc)}
  defp read_string(<<char, rest::binary>>, acc), do: read_string(rest, [acc, char])

  @spec set_search_term(%Query{}, String.t(), section(), term_type()) :: %Query{}
  defp set_search_term(query, term, section, type)

  defp set_search_term(query, "-" <> term, section, nil),
    do: Map.update!(query, section, fn val -> Map.update!(val, :exclude, &(&1 ++ [String.trim(term)])) end)

  defp set_search_term(query, "+" <> term, section, nil),
    do: Map.update!(query, section, fn val -> Map.update!(val, :include, &(&1 ++ [String.trim(term)])) end)

  defp set_search_term(query, term, section, nil),
    do: Map.update!(query, section, fn val -> Map.update!(val, :include, &(&1 ++ [String.trim(term)])) end)

  defp set_search_term(query, term, section, type),
    do: Map.update!(query, section, fn val -> Map.update!(val, type, &(&1 ++ [String.trim(term)])) end)
end
