defmodule Cforum.Forums.Forum do
  use CforumWeb, :model

  @primary_key {:forum_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :slug}

  @read "read"
  @write "write"
  @known_read "known-read"
  @known_write "known-write"

  def read(), do: @read
  def write(), do: @write
  def known_read(), do: @known_read
  def known_write(), do: @known_write

  schema "forums" do
    field :slug, :string
    field :short_name, :string
    field :name, :string
    field :description, :string
    field :standard_permission, :string
    field :keywords, :string
    field :position, :integer

    has_many :threads, Cforum.Forums.Thread
    has_many :messages, Cforum.Forums.Message

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:slug, :short_name, :name, :description, :standard_permission, :keywords, :position])
    |> validate_required([:slug, :short_name, :name, :description, :standard_permission, :position])
    |> unique_constraint(:slug)
  end
end
