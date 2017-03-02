defmodule Cforum.Notification do
  use Cforum.Web, :model

  schema "notifications" do
    field :is_read, :boolean, default: false
    field :subject, :string
    field :path, :string
    field :icon, :string
    field :oid, :integer
    field :otype, :string
    field :description, :string
    belongs_to :recipient, Cforum.User

    timestamps()
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
