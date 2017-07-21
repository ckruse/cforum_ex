defmodule Cforum.Accounts.BadgeUser do
  use Cforum.Web, :model

  @primary_key {:badge_user_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :badge_user_id}

  schema "badges_users" do
    belongs_to :badge, Cforum.Accounts.Badge, references: :badge_id
    belongs_to :user, Cforum.Accounts.User, references: :user_id

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
