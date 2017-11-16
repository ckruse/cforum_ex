defmodule Cforum.Forums.Tag do
  use CforumWeb, :model

  @primary_key {:tag_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :slug}

  schema "tags" do
    field(:tag_name, :string)
    field(:slug, :string)
    field(:num_messages, :integer)
    field(:suggest, :boolean, default: false)

    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)

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
    |> cast(params, [:tag_name, :slug, :num_messages, :suggest])
    |> validate_required([:tag_name, :slug, :num_messages, :suggest])
    |> unique_constraint(:slug)
  end
end
