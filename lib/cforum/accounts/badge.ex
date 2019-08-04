defmodule Cforum.Accounts.Badge do
  use CforumWeb, :model
  use Cforum.Accounts.Constants

  @primary_key {:badge_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :badge_id}

  schema "badges" do
    field(:score_needed, :integer)
    field(:name, :string)
    field(:description, :string)
    field(:slug, :string)
    field(:badge_medal_type, :string)
    field(:badge_type, :string)
    field(:order, :integer)

    has_many(:badges_users, Cforum.Accounts.BadgeUser, foreign_key: :badge_id)
    has_many(:users, through: [:badges_users, :user])

    many_to_many(:badges, Cforum.Accounts.BadgeGroup,
      join_through: "badges_badge_groups",
      on_delete: :delete_all,
      join_keys: [badge_id: :badge_id, badge_group_id: :badge_group_id]
    )

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:score_needed, :name, :description, :slug, :badge_medal_type, :badge_type, :order])
    |> validate_required([:name, :slug, :badge_medal_type, :badge_type, :order])
    |> unique_constraint(:slug, name: :badges_slug_key)
    |> unique_constraint(:badge_type, name: :badges_badge_type_idx)
    |> validate_inclusion(:badge_type, @badge_types)
    |> validate_inclusion(:badge_medal_type, @badge_medal_types)
  end
end
