defmodule Cforum.Forums.TagSynonym do
  use CforumWeb, :model

  @primary_key {:tag_synonym_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :tag_synonym_id}

  schema "tag_synonyms" do
    field(:synonym, :string)
    belongs_to(:tag, Cforum.Forums.Tag, references: :tag_id)
    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, tag, params \\ %{}) do
    struct
    |> cast(params, [:synonym])
    |> put_change(:tag_id, tag.tag_id)
    |> put_change(:forum_id, tag.forum_id)
    |> validate_required([:synonym, :tag_id, :forum_id])
    |> unique_constraint(:synonym, name: :tag_synonyms_forum_id_synonym_idx)
  end
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Forums.TagSynonym do
  def audit_json(synonym) do
    tag =
      case synonym.tag do
        %Ecto.Association.NotLoaded{} -> Cforum.Forums.Tags.get_tag!(synonym.tag_id)
        tag -> tag
      end

    %{"synonym" => synonym.synonym, "tag" => %{"tag_name" => tag.tag_name, "tag_id" => tag.tag_id}}
  end
end
