defmodule Cforum.Forums.Forum do
  use CforumWeb, :model

  @primary_key {:forum_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :slug}

  @type t() :: %__MODULE__{}

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
    field(:active, :boolean, default: true)

    has_many(:threads, Cforum.Threads.Thread, foreign_key: :forum_id)
    has_many(:messages, Cforum.Messages.Message, foreign_key: :forum_id)
    has_many(:permissions, Cforum.Groups.ForumGroupPermission, foreign_key: :forum_id)
    has_one(:setting, Cforum.Settings.Setting, foreign_key: :forum_id)

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:slug, :short_name, :name, :description, :standard_permission, :keywords, :position, :active])
    |> cast_assoc(:setting)
    |> validate_required([:slug, :short_name, :name, :description, :standard_permission, :position])
    |> validate_inclusion(:standard_permission, @permissions)
    |> validate_slug()
  end

  defp validate_slug(changeset) do
    changeset
    |> validate_exclusion(:slug, [
      "api",
      "admin",
      "notifications",
      "mails",
      "events",
      "invisible",
      "subscriptions",
      "interesting",
      "moderation",
      "login",
      "logout",
      "registrations",
      "help",
      "badges",
      "cites",
      "archiv",
      "images"
    ])
    |> validate_format(:slug, ~r/^[a-z0-9-]{2,}$/)
    |> validate_length(:slug, min: 2, max: 50)
    |> unique_constraint(:slug, name: :forums_slug_idx)
    |> validate_inclusion(:standard_permission, @permissions)
  end
end
