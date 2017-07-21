defmodule Cforum.Forums.Vote do
  use Cforum.Web, :model

  @primary_key {:vote_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :vote_id}

  schema "votes" do
    field :vtype, :string
    belongs_to :user, Cforum.Accounts.User, references: :user_id
    belongs_to :message, Cforum.Forums.Message, references: :message_id
    has_one :score, Cforum.Accounts.Score, foreign_key: :vote_id
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
