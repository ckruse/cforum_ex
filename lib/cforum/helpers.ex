defmodule Cforum.Helpers do
  @doc """
  Returns true for all „blank“ values: nil, empty string, 0, false,
  empty list, empty map

      iex> blank?("")
      true

      iex> blank?("foo")
      false
  """
  def blank?(nil), do: true
  def blank?(""), do: true
  def blank?(0), do: true
  def blank?(false), do: true
  def blank?([]), do: true
  def blank?(%Ecto.Association.NotLoaded{}), do: true
  def blank?(map) when map == %{}, do: true
  def blank?(_), do: false

  @doc """
  Returns true for all non-blank values

  ### Examples

      iex> present?("foo")
      true

      iex> present?("")
      false
  """
  def present?(v), do: not blank?(v)

  @doc """
  Converts values to integer, depending on the value itself:

  - When nil, empty string, empty list or empty map return 0
  - When true return 1
  - When value is a String try to parse it to an Integer
  - Return the value itself when it is an Integer
  - Return zero otherwise

  ### Examples

      iex> to_int(10)
      10

      iex> to_int("10")
      10

      iex> to_int(3.1)
      3
  """
  def to_int(v) when is_nil(v), do: 0
  def to_int(""), do: 0
  def to_int([]), do: 0
  def to_int(true), do: 1
  def to_int(false), do: 0
  def to_int(map) when map == %{}, do: 0
  def to_int(v) when is_bitstring(v), do: String.to_integer(v)
  def to_int(v) when is_integer(v), do: v
  def to_int(v) when is_number(v), do: trunc(v)
  def to_int(_v), do: 0

  @doc """
  Returns the `attribute` value of a `struct` when it is not `nil` and the attribute value is set

  returns `default_value` otherwise
  """
  def attribute_value(struct, attribute, default_value \\ nil)
  def attribute_value(nil, _, default), do: default

  def attribute_value(struct, field, default) do
    case Map.get(struct, field, default) do
      nil ->
        default

      v ->
        v
    end
  end

  @doc """
  Adds a value to a list if the test is true
  """
  def add_if(list, true, value), do: [value | list]
  def add_if(list, _, _value), do: list

  def map_maybe_delete(map, key, true), do: Map.delete(map, key)
  def map_maybe_delete(map, _, _), do: map

  @spec score_str(integer(), integer()) :: String.t()
  def score_str(votes, _score) when votes == 0, do: "–"
  def score_str(_votes, score) when score == 0, do: "±0"
  def score_str(_votes, score) when score < 0, do: "−" <> Integer.to_string(abs(score))
  def score_str(_votes, score), do: "+" <> Integer.to_string(abs(score))

  def strip_changeset_changes(changeset) do
    str_changes =
      changeset.changes
      |> Map.keys()
      |> Enum.filter(&(changeset.data.__struct__.__schema__(:type, &1) == :string))
      |> Enum.filter(&(Ecto.Changeset.get_change(changeset, &1) != nil))

    Enum.reduce(str_changes, changeset, fn key, changeset ->
      Ecto.Changeset.update_change(changeset, key, &String.trim/1)
    end)
  end

  @doc """
  Truncates the string `str` after `words_count` words
  """
  def truncate_words(str, words_count, options \\ [omission: "…", separator: "\\s+"]) do
    sep = options[:separator] || "\\s+"
    {:ok, re} = Regex.compile("\\A((?>.+?#{sep}){#{words_count - 1}}.+?)#{sep}.*")

    case Regex.run(re, str) do
      nil ->
        str

      [_, val] ->
        val <> (options[:omission] || "…")

      v ->
        raise inspect(v)
    end
  end
end
