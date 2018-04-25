defmodule Cforum.Forums.Forum do
  use CforumWeb, :model

  @primary_key {:forum_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :slug}

  @read "read"
  @write "write"
  @known_read "known-read"
  @known_write "known-write"
  @private "private"
  @permissions [@read, @write, @known_read, @known_write, @private]

  def read(), do: @read
  def write(), do: @write
  def known_read(), do: @known_read
  def known_write(), do: @known_write

  schema "forums" do
    field(:slug, :string)
    field(:short_name, :string)
    field(:name, :string)
    field(:description, :string)
    field(:standard_permission, :string)
    field(:keywords, :string)
    field(:position, :integer)

    has_many(:threads, Cforum.Forums.Thread, foreign_key: :forum_id)
    has_many(:messages, Cforum.Forums.Message, foreign_key: :forum_id)
    has_many(:permissions, Cforum.Accounts.ForumGroupPermission, foreign_key: :forum_id)
    has_one(:setting, Cforum.Accounts.Setting, foreign_key: :forum_id)

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:slug, :short_name, :name, :description, :standard_permission, :keywords, :position])
    |> cast_assoc(:setting)
    |> validate_required([:slug, :short_name, :name, :description, :standard_permission, :position])
    |> validate_inclusion(:standard_permission, @permissions)
    |> unique_constraint(:slug)
  end
end
