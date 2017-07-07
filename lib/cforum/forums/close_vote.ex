defmodule Cforum.Forums.CloseVote do
  use Cforum.Web, :model

  @primary_key {:close_vote_id, :integer, []}
  @derive {Phoenix.Param, key: :close_vote_id}

  schema "close_votes" do
    field :reason, :string
    field :duplicate_slug, :string
    field :custom_reason, :string
    field :finished, :boolean, default: false
    field :vote_type, :boolean, default: false

    belongs_to :message, Cforum.Forums.Message, references: :message_id
    has_many :voters, Cforum.Forums.CloseVoteVoter, references: :close_vote_id, foreign_key: :close_vote_id

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:reason, :duplicate_slug, :custom_reason, :finished, :vote_type])
    |> validate_required([:reason, :duplicate_slug, :custom_reason, :finished, :vote_type])
  end
end
