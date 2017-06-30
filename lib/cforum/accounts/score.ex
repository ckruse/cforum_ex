defmodule Cforum.Accounts.Score do
  use Cforum.Web, :model

  @primary_key {:score_id, :integer, []}
  @derive {Phoenix.Param, key: :score_id}

  schema "scores" do
    field :value, :integer
    field :created_at, :utc_datetime

    belongs_to :user, Cforum.Accounts.User, references: :user_id
    belongs_to :vote, Cforum.Forums.Threads.Vote, references: :vote_id
    belongs_to :message, Cforum.Forums.Threads.Message, references: :message_id
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value])
    |> validate_required([:value])
  end

  def get_message(%Cforum.Accounts.Score{vote_id: vid, message_id: mid}) when is_nil(vid) and is_nil(mid), do: nil
  def get_message(score = %Cforum.Accounts.Score{vote_id: vid}) when vid == nil, do: score.message
  def get_message(score), do: score.vote.message
end
