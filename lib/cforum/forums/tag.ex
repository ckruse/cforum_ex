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

    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
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
  def changeset(struct, forum, params \\ %{}) do
    struct
    |> cast(params, [:tag_name, :suggest])
    |> maybe_set_slug()
    |> maybe_put_forum_id(forum)
    |> validate_required([:tag_name, :slug, :forum_id, :suggest])
    |> unique_constraint(:slug, name: :tags_tag_name_forum_id_idx)
  end

  defp maybe_set_slug(%Changeset{valid?: true} = changeset) do
    with slug when is_nil(slug) <- Changeset.get_field(changeset, :slug),
         name when not is_nil(name) <- Changeset.get_field(changeset, :tag_name) do
      slug = name |> Slug.slugify() |> String.downcase()
      Changeset.put_change(changeset, :slug, slug)
    else
      _ -> changeset
    end
  end

  defp maybe_set_slug(changeset), do: changeset

  defp maybe_put_forum_id(changeset, nil), do: changeset

  defp maybe_put_forum_id(%Changeset{valid?: true} = changeset, forum) do
    if Changeset.get_field(changeset, :forum_id) == nil,
      do: Changeset.put_change(changeset, :forum_id, forum.forum_id),
      else: changeset
  end

  defp maybe_put_forum_id(changeset, _), do: changeset
end
