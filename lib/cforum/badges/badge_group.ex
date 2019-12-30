defmodule Cforum.Badges.BadgeGroup do
  use CforumWeb, :model

  @primary_key {:badge_group_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :badge_group_id}

  schema "badge_groups" do
    field(:name, :string)

    many_to_many(:badges, Cforum.Badges.Badge,
      join_through: "badges_badge_groups",
      on_delete: :delete_all,
      join_keys: [badge_group_id: :badge_group_id, badge_id: :badge_id]
    )

    timestamps(inserted_at: :created_at)
  end

  # def changeset(struct, params \\ %{}) do
  #   struct
  #   |> cast(params, [:score_needed, :name, :description, :slug, :badge_medal_type, :badge_type, :order])
  #   |> validate_required([:name, :slug, :badge_medal_type, :badge_type, :order])
  #   |> unique_constraint(:slug, name: :badges_slug_key)
  #   |> unique_constraint(:badge_type, name: :badges_badge_type_idx)
  #   |> validate_inclusion(:badge_type, @badge_types)
  #   |> validate_inclusion(:badge_medal_type, @badge_medal_types)
  # end
end
