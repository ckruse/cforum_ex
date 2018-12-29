defmodule Cforum.System.Auditing do
  use CforumWeb, :model

  @primary_key {:auditing_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :auditing_id}

  schema "auditing" do
    field(:act, :string)
    field(:contents, :map, default: %{})
    field(:relation, :string)
    field(:relid, :integer)

    belongs_to(:user, Cforum.Accounts.User, references: :user_id)

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  @doc false
  def changeset(auditing, attrs) do
    auditing
    |> cast(attrs, [:relation, :relid, :act, :contents, :user_id])
    |> validate_required([:relation, :relid, :act, :contents])
  end
end
