defmodule Cforum.Accounts.Notification do
  use Cforum.Web, :model

  @primary_key {:notification_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :notification_id}

  schema "notifications" do
    field :is_read, :boolean, default: false
    field :subject, :string
    field :path, :string
    field :icon, :string
    field :oid, :integer
    field :otype, :string
    field :description, :string
    belongs_to :recipient, Cforum.Accounts.User, references: :user_id

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:is_read, :subject, :path, :icon, :oid, :otype, :description])
    |> validate_required([:is_read, :subject, :path, :icon, :oid, :otype, :description])
  end
end
