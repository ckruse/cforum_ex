defmodule Cforum.Accounts.Notification do
  use CforumWeb, :model

  @primary_key {:notification_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :notification_id}
  @derive {Poison.Encoder, only: [:is_read, :subject, :path, :icon, :oid, :otype, :description, :recipient]}

  schema "notifications" do
    field(:is_read, :boolean, default: false)
    field(:subject, :string)
    field(:path, :string)
    field(:icon, :string)
    field(:oid, :integer)
    field(:otype, :string)
    field(:description, :string)
    belongs_to(:recipient, Cforum.Accounts.User, references: :user_id)

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:is_read, :subject, :path, :icon, :oid, :otype, :description, :recipient_id])
    |> validate_required([:is_read, :subject, :path, :oid, :otype, :recipient_id])
  end
end
