defmodule Cforum.Forums.Tag do
  use CforumWeb, :model

  alias Ecto.Changeset

  @primary_key {:tag_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :slug}

  schema "tags" do
    field(:tag_name, :string)
    field(:slug, :string)
    field(:num_messages, :integer)
    field(:suggest, :boolean, default: false)

    has_many(:synonyms, Cforum.Forums.TagSynonym, foreign_key: :tag_id)

    many_to_many(
      :messages,
      Cforum.Forums.Message,
      join_through: Cforum.Forums.MessageTag,
      join_keys: [tag_id: :tag_id, message_id: :message_id]
    )
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:tag_name, :suggest])
    |> maybe_set_slug()
    |> validate_required([:tag_name, :slug, :suggest])
    |> unique_constraint(:slug, name: :tags_lower_tag_name_idx)
  end

  defp maybe_set_slug(%Changeset{valid?: true} = changeset) do
    with name when not is_nil(name) <- Changeset.get_field(changeset, :tag_name) do
      slug = name |> Slug.slugify() |> String.downcase()
      Changeset.put_change(changeset, :slug, slug)
    else
      _ -> changeset
    end
  end

  defp maybe_set_slug(changeset), do: changeset
end
