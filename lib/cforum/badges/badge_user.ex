defmodule Cforum.Badges.BadgeUser do
  use CforumWeb, :model

  @primary_key {:badge_user_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :badge_user_id}

  schema "badges_users" do
    field(:active, :boolean, default: true)

    belongs_to(:badge, Cforum.Badges.Badge, references: :badge_id)
    belongs_to(:user, Cforum.Users.User, references: :user_id)

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:active, :badge_id, :user_id])
    |> validate_required([:active, :badge_id, :user_id])
  end
end
