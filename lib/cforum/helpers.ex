defmodule Cforum.Helpers do
  @doc """
  Returns true for all „blank“ values: nil, empty string, 0, false,
  empty list, empty map

      iex> blank?("")
      true

      iex> blank?("foo")
      false
  """
  @spec blank?(any()) :: boolean()
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
  @spec present?(any()) :: boolean()
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
  @spec to_int(any()) :: integer()
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
  Converts values to float, depending on the value itself:

  - When nil, empty string, empty list or empty map return 0.0
  - When true return 1.0
  - When value is a String try to parse it to an Float
  - Return the value itself when it is an Float
  - Return zero otherwise

  ### Examples

      iex> to_float(10)
      10.0

      iex> to_float("10")
      10.0

      iex> to_float(3.1)
      3.0
  """
  @spec to_float(any()) :: float()
  def to_float(v) when is_nil(v), do: 0.0
  def to_float(""), do: 0.0
  def to_float([]), do: 0.0
  def to_float(true), do: 1.0
  def to_float(false), do: 0.0
  def to_float(map) when map == %{}, do: 0.0
  def to_float(v) when is_bitstring(v), do: String.to_float(v)
  def to_float(v) when is_float(v), do: v
  def to_float(v) when is_number(v), do: v / 1
  def to_float(_v), do: 0.0

  @doc """
  Returns the `attribute` value of a `struct` when it is not `nil` and the attribute value is set

  returns `default_value` otherwise
  """
  @spec attribute_value(struct() | nil, atom(), any()) :: any()
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
  @spec add_if(list(), boolean(), any()) :: list()
  def add_if(list, true, value), do: [value | list]
  def add_if(list, _, _value), do: list

  @spec map_maybe_delete(map(), any(), boolean()) :: map()
  def map_maybe_delete(map, key, true), do: Map.delete(map, key)
  def map_maybe_delete(map, _, _), do: map

  def map_maybe_set(map, key, value, true), do: Map.put(map, key, value)
  def map_maybe_set(map, _, _, _), do: map

  @spec score_str(integer(), integer()) :: String.t()
  def score_str(votes, _score) when votes == 0, do: "–"
  def score_str(_votes, score) when score == 0, do: "±0"
  def score_str(_votes, score) when score < 0, do: "−" <> Integer.to_string(abs(score))
  def score_str(_votes, score), do: "+" <> Integer.to_string(abs(score))

  @spec strip_changeset_changes(%Ecto.Changeset{}) :: %Ecto.Changeset{}
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

  @spec changeset_changes_to_normalized_newline(%Ecto.Changeset{}) :: %Ecto.Changeset{}
  def changeset_changes_to_normalized_newline(changeset) do
    str_changes =
      changeset.changes
      |> Map.keys()
      |> Enum.filter(&(changeset.data.__struct__.__schema__(:type, &1) == :string))
      |> Enum.filter(&(Ecto.Changeset.get_change(changeset, &1) != nil))

    Enum.reduce(str_changes, changeset, fn key, changeset ->
      Ecto.Changeset.update_change(changeset, key, &Regex.replace(~r/\015\012|\015|\012/, &1, "\n"))
    end)
  end

  @spec maybe_put_change(Ecto.Changeset.t(), atom(), any()) :: Ecto.Changeset.t()
  def maybe_put_change(changeset, _, nil), do: changeset
  def maybe_put_change(changeset, field, value), do: Ecto.Changeset.put_change(changeset, field, value)

  @spec maybe_put_change(Ecto.Changeset.t(), atom(), String.t()) :: Ecto.Changeset.t()
  def validate_blacklist(changeset, field, conf_key) do
    forum_id = Ecto.Changeset.get_field(changeset, :forum_id)

    settings = get_settings(forum_id, nil, nil)
    blacklist = Cforum.ConfigManager.conf(settings, conf_key)
    value = Ecto.Changeset.get_field(changeset, field)

    if matches?(value, blacklist),
      do: Ecto.Changeset.add_error(changeset, field, "seems like spam!"),
      else: changeset
  end

  defp matches?(str, list) when is_nil(str) or str == "" or is_nil(list) or list == "", do: false

  defp matches?(str, list) do
    list
    |> String.split(~r/\015\012|\015|\012/)
    |> Enum.reject(&blank?/1)
    |> Enum.any?(fn rx ->
      regex = Regex.compile!(rx, "i")
      Regex.match?(regex, str)
    end)
  end

  @spec get_settings(any() | nil, map() | nil, Cforum.Messages.Message.t() | nil) :: Cforum.ConfigManager.conf_map()
  def get_settings(forum_id, params, msg) do
    given_forum_id =
      cond do
        present?(params) && present?(params["forum_id"]) -> params["forum_id"]
        present?(params) && present?(params[:forum_id]) -> params[:forum_id]
        present?(forum_id) -> forum_id
        present?(msg) -> msg.forum_id
        true -> nil
      end

    forum =
      if present?(given_forum_id),
        do: Cforum.Forums.get_forum!(given_forum_id),
        else: nil

    Cforum.ConfigManager.settings_map(forum, nil)
  end

  @doc """
  Truncates the string `str` after `words_count` words
  """
  @spec truncate_words(String.t(), integer(), omission: String.t(), separator: String.t()) :: String.t()
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

  def validate_url(changeset, field, opts \\ []) do
    Ecto.Changeset.validate_change(changeset, field, fn _, value ->
      case URI.parse(value) do
        %URI{scheme: scheme} when scheme not in ["http", "https"] -> "has an invalid scheme"
        %URI{host: nil} -> "is missing a host"
        _ -> nil
      end
      |> case do
        error when is_binary(error) -> [{field, Keyword.get(opts, :message, error)}]
        _ -> []
      end
    end)
  end

  def bool_value(value, default_value \\ true)
  def bool_value(true, _), do: true
  def bool_value(false, _), do: false
  def bool_value(nil, default), do: default

  def bool_value(value, _) do
    if present?(value),
      do: true,
      else: false
  end
end
