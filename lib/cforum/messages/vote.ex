defmodule Cforum.Messages.Vote do
  use CforumWeb, :model

  @primary_key {:vote_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :vote_id}

  @upvote "upvote"
  @downvote "downvote"
  @valid_vtypes [@upvote, @downvote]

  schema "votes" do
    field(:vtype, :string)
    belongs_to(:user, Cforum.Accounts.User, references: :user_id)
    belongs_to(:message, Cforum.Messages.Message, references: :message_id)
    has_one(:score, Cforum.Accounts.Score, foreign_key: :vote_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:vtype, :user_id, :message_id])
    |> validate_required([:vtype, :user_id, :message_id])
    |> validate_inclusion(:vtype, @valid_vtypes)
  end

  def upvote, do: @upvote
  def downvote, do: @downvote
end
