defmodule CforumWeb.Messages.RetagView do
  use CforumWeb, :view

  alias Cforum.ConfigManager

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  def page_title(_, assigns), do: gettext("Retag message “%{subject}”", subject: assigns.message.subject)
  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(_, _), do: "retag-message"
  def body_classes(_, _), do: "retag message"

  defp tags_from_changeset(changeset) do
    case Ecto.Changeset.get_change(changeset, :tags) do
      nil ->
        changeset
        |> Ecto.Changeset.get_field(:tags, [])
        |> Enum.map(&Ecto.Changeset.change(&1))

      changes ->
        changes
    end
  end

  defp tags_and_index_from_changeset(changeset),
    do: changeset |> tags_from_changeset() |> Enum.with_index()

  defp no_tag_inputs_left(conn, changeset) do
    cnt = length(tags_from_changeset(changeset))
    max = ConfigManager.conf(conn, "max_tags_per_message")

    if cnt >= max,
      do: [],
      else: (cnt + 1)..max
  end
end
