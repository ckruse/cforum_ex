defmodule Cforum.Accounts.PrivMessage do
  use Cforum.Web, :model

  @primary_key {:priv_message_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :priv_message_id}

  schema "priv_messages" do
    belongs_to :sender, Cforum.Accounts.User, references: :user_id
    belongs_to :recipient, Cforum.Accounts.User, references: :user_id
    belongs_to :owner, Cforum.Accounts.User, references: :user_id

    field :is_read, :boolean, default: false
    field :subject, :string
    field :body, :string
    field :sender_name, :string
    field :recipient_name, :string
    field :thread_id, :integer

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
