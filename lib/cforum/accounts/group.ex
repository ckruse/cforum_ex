defmodule Cforum.Accounts.Group do
  use CforumWeb, :model

  alias Cforum.Accounts.Group

  @primary_key {:group_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :group_id}

  schema "groups" do
    field(:name, :string)

    many_to_many(
      :users,
      Cforum.Accounts.User,
      join_through: "groups_users",
      on_delete: :delete_all,
      unique: true,
      join_keys: [group_id: :group_id, user_id: :user_id]
    )

    has_many(:permissions, Cforum.Accounts.ForumGroupPermission, foreign_key: :group_id)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(%Group{} = group, attrs) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
