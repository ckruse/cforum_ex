defmodule Cforum.Score do
  use Cforum.Web, :model

  schema "scores" do
    field :value, :integer
    belongs_to :user, Cforum.User
    belongs_to :vote, Cforum.Vote
    belongs_to :message, Cforum.Message

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value])
    |> validate_required([:value])
  end
end
