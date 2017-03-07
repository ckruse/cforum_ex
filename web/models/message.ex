defmodule Cforum.Message do
  use Cforum.Web, :model

  @primary_key {:message_id, :integer, []}
  @derive {Phoenix.Param, key: :message_id}

  schema "messages" do
    field :upvotes, :integer
    field :downvotes, :integer
    field :deleted, :boolean, default: false
    field :mid, :integer
    field :author, :string
    field :email, :string
    field :homepage, :string
    field :subject, :string
    field :content, :string
    field :flags, :map
    field :uuid, :string
    field :ip, :string
    field :format, :string
    field :edit_author, :string
    field :problematic_site, :string

    field :messages, :any, virtual: true
    field :attribs, :map, virtual: true

    belongs_to :thread, Cforum.Thread, references: :forum_id
    belongs_to :forum, Cforum.Forum, references: :forum_id
    belongs_to :user, Cforum.User, references: :user_id
    belongs_to :parent, Cforum.Message, references: :message_id
    belongs_to :editor, Cforum.User, references: :user_id

    many_to_many :tags, Cforum.Tag, join_through: Cforum.MessageTag, join_keys: [message_id: :message_id, tag_id: :tag_id]
    has_many :votes, Cforum.CloseVote, foreign_key: :message_id

    timestamps(inserted_at: :created_at)
  end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:upvotes, :downvotes, :deleted, :mid, :author, :email, :homepage, :subject, :content, :flags, :uuid, :up, :format, :edit_author, :problematic_site])
    |> validate_required([:upvotes, :downvotes, :deleted, :mid, :author, :email, :homepage, :subject, :content, :flags, :uuid, :up, :format, :edit_author, :problematic_site])
  end
end
