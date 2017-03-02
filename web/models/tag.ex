defmodule Cforum.Tag do
  use Cforum.Web, :model

  schema "tags" do
    field :tag_name, :string
    field :slug, :string
    field :num_messages, :integer
    field :suggest, :boolean, default: false

    belongs_to :forum, Cforum.Forum

    many_to_many :messages, Cforum.Message, join_through: "messages_tags"

    timestamps()
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
