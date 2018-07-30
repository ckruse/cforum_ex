defmodule Cforum.Forums.CloseVoteVoter do
  use CforumWeb, :model

  @primary_key {:close_votes_voter_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :close_votes_voter_id}

  schema "close_votes_voters" do
    belongs_to(:close_vote, Cforum.Forums.CloseVote, references: :close_vote_id)
    belongs_to(:user, Cforum.Accounts.User, references: :user_id)

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:close_vote_id, :user_id])
    |> validate_required([:close_vote_id, :user_id])
    |> unique_constraint(:user_id, name: :close_votes_voters_close_vote_id_user_id_key)
  end
end
