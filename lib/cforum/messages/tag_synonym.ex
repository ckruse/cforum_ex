defmodule Cforum.Messages.TagSynonym do
  use CforumWeb, :model

  @primary_key {:tag_synonym_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :tag_synonym_id}

  schema "tag_synonyms" do
    field(:synonym, :string)
    belongs_to(:tag, Cforum.Messages.Tag, references: :tag_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, tag, params \\ %{}) do
    struct
    |> cast(params, [:synonym])
    |> put_change(:tag_id, tag.tag_id)
    |> validate_required([:synonym, :tag_id])
    |> unique_constraint(:synonym, name: :tag_synonyms_synonym_idx)
  end
end
