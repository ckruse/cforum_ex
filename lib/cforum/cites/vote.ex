defmodule Cforum.Cites.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:cite_vote_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :cite_vote_id}

  @downvote 0
  @upvote 1
  @vote_types [@downvote, @upvote]

  def downvote(), do: @downvote
  def upvote(), do: @upvote

  schema "cites_votes" do
    field(:vote_type, :integer)

    belongs_to(:cite, Cforum.Cites.Cite, references: :cite_id)
    belongs_to(:user, Cforum.Accounts.User, references: :user_id)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:cite_id, :user_id, :vote_type])
    |> validate_required([:cite_id, :user_id, :vote_type])
    |> validate_inclusion(:vote_type, @vote_types)
    |> unique_constraint(:cite_id, name: :cites_votes_cite_id_user_id_idx)
  end

  def vtype("up"), do: @upvote
  def vtype("down"), do: @downvote
end
