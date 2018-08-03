defmodule Cforum.Search.Section do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:search_section_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :search_section_id}

  schema "search_sections" do
    field(:active_by_default, :boolean, default: false)
    field(:name, :string)
    field(:position, :integer)

    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, [:name, :position, :active_by_default, :forum_id])
    |> validate_required([:name, :position])
  end
end
