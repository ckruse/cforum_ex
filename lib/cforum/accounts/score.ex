defmodule Cforum.Accounts.Score do
  use CforumWeb, :model

  @primary_key {:score_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :score_id}

  schema "scores" do
    field :value, :integer

    belongs_to :user, Cforum.Accounts.User, references: :user_id
    belongs_to :vote, Cforum.Forums.Vote, references: :vote_id
    belongs_to :message, Cforum.Forums.Message, references: :message_id

    timestamps(inserted_at: :created_at, updated_at: nil)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :user_id, :vote_id, :message_id])
    |> validate_required([:value, :user_id])
  end

  def get_message(%Cforum.Accounts.Score{vote_id: vid, message_id: mid}) when is_nil(vid) and is_nil(mid), do: nil
  def get_message(score = %Cforum.Accounts.Score{vote_id: vid}) when vid == nil, do: score.message
  def get_message(score), do: score.vote.message
end
