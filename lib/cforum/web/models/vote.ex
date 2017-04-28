defmodule Cforum.Vote do
  use Cforum.Web, :model

  @primary_key {:vote_id, :integer, []}
  @derive {Phoenix.Param, key: :vote_id}

  schema "votes" do
    field :vtype, :string
    belongs_to :user, Cforum.User, references: :user_id
    belongs_to :message, Cforum.Message, references: :message_id
    has_one :score, Cforum.Score, foreign_key: :vote_id
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:vtype])
    |> validate_required([:vtype])
  end
end
