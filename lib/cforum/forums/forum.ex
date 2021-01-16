defmodule Cforum.Forums.Forum do
  use CforumWeb, :model
  use Cforum.Constants

  @primary_key {:forum_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :slug}

  schema "forums" do
    field(:slug, :string)
    field(:short_name, :string)
    field(:name, :string)
    field(:type, :string, default: "forum")
    field(:description, :string)
    field(:standard_permission, :string)
    field(:keywords, :string)
    field(:position, :integer)
    field(:active, :boolean, default: true)
    field(:visible, :boolean, default: true)

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
    |> cast(params, [
      :slug,
      :short_name,
      :name,
      :type,
      :description,
      :standard_permission,
      :keywords,
      :position,
      :active,
      :visible
    ])
    |> cast_assoc(:setting)
    |> validate_required([:slug, :short_name, :name, :type, :description, :standard_permission, :position])
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
    |> validate_format(:slug, ~r/\A[a-z0-9-]{2,}\z/)
    |> validate_length(:slug, min: 2, max: 50)
    |> unique_constraint(:slug, name: :forums_slug_idx)
    |> validate_inclusion(:standard_permission, @permissions)
    |> validate_inclusion(:type, ~w[forum blog])
  end
end
