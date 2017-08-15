defmodule CforumWeb.Views.Helpers do
  @moduledoc """
  This module contains some helpers for web rendering
  """

  use Phoenix.HTML
  import CforumWeb.Gettext

  alias Cforum.Helpers

  @doc """
  Returns true if a user is signed in, returns false otherwise

  ## Examples

      iex> signed_in?(conn)
      true
  """
  def signed_in?(conn) do
    conn.assigns[:current_user] != nil
  end

  @doc """
  This function formats a date by a format name. It looks up the format itself
  using `Cforum.ConfigManager.uconf`. `name` parameter defaults to `"date_format_default"`.

  ## Examples

      iex> date_format(Timex.DateTime{})
      "2017-01-01 00:00"

      iex> date_format(Timex.DateTime{}, "date_format_default")
      "2017-01-01 00:00"
  """
  def date_format(conn, name \\ "date_format_default") do
    val = Cforum.ConfigManager.uconf(conn, name)
    if Helpers.blank?(val), do: "%d.%m.%Y %H:%M", else: val
  end

  @doc """
  Returns true if a key in a changeset is blank or equal to a specified value. Helper for
  the user configuration and the admin interface, to distinguish between global config values
  and modified config values
  """
  def blank_or_value?(changeset, key, value) do
    field_val = Map.get(changeset, key)
    Helpers.blank?(field_val) || field_val == value
  end

  @doc """
  generates a „sub-form“ in a different namespace: the input fields will be prefixed
  with that namespace. If i.e. called with `field` set to `foo[bar]` the generated
  field names look like this: `foo[bar][baz]`
  """
  def sub_inputs(form, field, _options \\ [], fun) do
    # options =
    #   form.options
    #   |> Keyword.take([:multipart])
    #   |> Keyword.merge(options)

    attr = Map.get(form.data, field) || %{}
    symbolized_attr = Enum.reduce(Map.keys(attr), %{}, fn(key, map) -> Map.put(map, String.to_atom(key), attr[key]) end)
    types = Enum.reduce(Map.keys(symbolized_attr), %{}, fn(key, map) -> Map.put(map, key, :string) end)

    changeset = Ecto.Changeset.cast({symbolized_attr, types}, form.params, Map.keys(symbolized_attr))
    forms = Phoenix.HTML.FormData.to_form(changeset, as: form.name <> "[#{field}]")

    fun.(forms)
  end

  defp ecto_to_seconds(datetime) do
    :calendar.datetime_to_gregorian_seconds(:calendar.local_time()) - :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(datetime))
  end

  @doc """
  Generates a relative time text, e.g. "less than 5 seconds" or "about an hour"
  """
  def relative_time(%Ecto.DateTime{} = time) do
    relative_time(ecto_to_seconds(time))
  end
  def relative_time(%DateTime{} = time) do
    relative_time(Timex.diff(Timex.now, time, :seconds))
  end
  def relative_time(seconds) do
    minutes = round(seconds / 60)

    case minutes do
      minutes when minutes in 0..1 ->
        case seconds do
          seconds when seconds in 0..4 ->
            gettext("less than 5 seconds")
          seconds when seconds in 5..9 ->
            gettext("less than 10 seconds")
          seconds when seconds in 10..19 ->
            gettext("less than 20 seconds")
          seconds when seconds in 20..39 ->
            gettext("half a minute")
          seconds when seconds in 40..59 ->
            gettext("less than a minute")
          _ ->
            gettext("1 minute")
        end
      minutes when minutes in 2..44 ->
        gettext("%{minutes} minutes", minutes: minutes)
      minutes when minutes in 45..89 ->
        gettext("about an hour")
      minutes when minutes in 90..1439 ->
        gettext("about %{hours} hours", hours: round(minutes / 60))
      minutes when minutes in 1440..2519 ->
        gettext("a day")
      minutes when minutes in 2_520..43_199 ->
        gettext("%{days} days", days: round(minutes / 1440))
      minutes when minutes in 43_200..86_399 ->
        gettext("about 1 month")
      minutes when minutes in 86_400..525_599 ->
        gettext("%{months} months", months: round(minutes / 43_200))
      minutes when minutes in 525_600..1_051_199 ->
        gettext("1 year")
      _ ->
        gettext("%{years} years", years: round(minutes / 525_600))
    end
  end

  @doc """
  Generates a time tag with the correct `datetime` attribute and the given content
  """
  def time_tag(opts, [do: content]) do
    timestamp = DateTime.to_iso8601(opts[:time])
    content_tag(:time, content, Keyword.merge([datetime: timestamp], opts) |> Keyword.delete(:time))
  end
  def time_tag(content, opts) do
    timestamp = DateTime.to_iso8601(opts[:time])
    content_tag(:time, content, Keyword.merge([datetime: timestamp], opts) |> Keyword.delete(:time))
  end
end
