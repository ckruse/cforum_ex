defmodule CforumWeb.Views.Helpers do
  use Phoenix.HTML

  alias Cforum.Helpers

  def signed_in?(conn) do
    conn.assigns[:current_user] != nil
  end

  def date_format(conn, name \\ "date_format_default") do
    val = Cforum.ConfigManager.uconf(conn, name)
    if Helpers.blank?(val), do: "%d.%m.%Y %H:%M", else: val
  end

  def blank_or_value?(changeset, key, value) do
    field_val = Map.get(changeset, key)
    Helpers.blank?(field_val) || field_val == value
  end

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

end
