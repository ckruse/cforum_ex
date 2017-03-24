defmodule Cforum.Badge do
  use Cforum.Web, :model

  @primary_key {:badge_id, :integer, []}
  @derive {Phoenix.Param, key: :badge_id}

  schema "badges" do
    field :score_needed, :integer
    field :name, :string
    field :description, :string
    field :slug, :string
    field :badge_medal_type, :string
    field :badge_type, :string
    field :order, :integer

    has_many :badges_users, Cforum.BadgeUser, foreign_key: :badge_id
    has_many :users, through: [:badges_users, :user]

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:reason, :duplicate_slug, :custom_reason, :finished, :vote_type])
    |> validate_required([:reason, :duplicate_slug, :custom_reason, :finished, :vote_type])
  end
end
