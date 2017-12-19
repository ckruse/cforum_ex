defmodule Cforum.Forums.TagSynonym do
  use CforumWeb, :model

  @primary_key {:tag_synonym_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :tag_synonym_id}

  schema "tag_synonyms" do
    field(:synonym, :string)
    belongs_to(:tag, Cforum.Forums.Tag, references: :tag_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:synonym, :tag_id])
    |> validate_required([:synonym, :tag_id])
    |> unique_constraint([:synonym, :tag_id])
  end
end
