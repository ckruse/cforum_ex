defmodule Cforum.Thread do
  use Cforum.Web, :model

  @primary_key {:thread_id, :integer, []}
  @derive {Phoenix.Param, key: :thread_id}

  schema "threads" do
    field :archived, :boolean, default: false
    field :tid, :integer
    field :deleted, :boolean, default: false
    field :sticky, :boolean, default: false
    field :flags, :map
    field :latest_message, Ecto.DateTime

    belongs_to :forum, Cforum.Forum
    belongs_to :message, Cforum.Message
    has_many :messages, Cforum.Message

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:archived, :tid, :deleted, :sticky, :flags, :latest_message])
    |> validate_required([:archived, :tid, :deleted, :sticky, :flags, :latest_message])
  end
end
