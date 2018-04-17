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
      on_replace: :delete,
      unique: true,
      join_keys: [group_id: :group_id, user_id: :user_id]
    )

    has_many(:permissions, Cforum.Accounts.ForumGroupPermission, foreign_key: :group_id, on_replace: :delete)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(%Group{} = group, attrs) do
    group
    |> cast(attrs, [:name])
    |> cast_assoc(:permissions)
    |> maybe_put_users(attrs)
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  defp maybe_put_users(changeset, %{"users" => users}), do: maybe_put_users(changeset, users)
  defp maybe_put_users(changeset, %{users: users}), do: maybe_put_users(changeset, users)
  defp maybe_put_users(changeset, []), do: changeset
  defp maybe_put_users(changeset, %{}), do: changeset
  defp maybe_put_users(changeset, nil), do: changeset
  defp maybe_put_users(changeset, users), do: put_assoc(changeset, :users, Cforum.Accounts.Users.get_users(users))
end
