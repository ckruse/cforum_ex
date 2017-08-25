defmodule Cforum.Forums.Thread do
  use CforumWeb, :model

  @primary_key {:thread_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :thread_id}

  def default_preloads, do: [:forum]
  def default_preloads(:messages), do: [:forum, messages: Cforum.Forums.Message.default_preloads]

  schema "threads" do
    field :archived, :boolean, default: false
    field :tid, :integer
    field :deleted, :boolean, default: false
    field :sticky, :boolean, default: false
    field :flags, :map
    field :latest_message, Timex.Ecto.DateTime
    field :slug, :string

    belongs_to :forum, Cforum.Forums.Forum, references: :forum_id
    #belongs_to :message, Cforum.Forums.Message, references: :message_id
    has_many :messages, Cforum.Forums.Message, foreign_key: :thread_id

    field :message, :any, virtual: true
    field :sorted_messages, :any, virtual: true
    field :tree, :any, virtual: true
    field :accepted, :any, virtual: true
    field :attribs, :map, virtual: true, default: %{}

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
