defmodule Cforum.Message do
  use Cforum.Web, :model

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
    field :up, :string
    field :format, :string
    field :edit_author, :string
    field :problematic_site, :string

    belongs_to :thread, Cforum.Thread
    belongs_to :forum, Cforum.Forum
    belongs_to :user, Cforum.User
    belongs_to :parent, Cforum.Message
    belongs_to :editor, Cforum.User

    many_to_many :tags, Cforum.Tag, join_through: "messages_tags"

    timestamps()
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
