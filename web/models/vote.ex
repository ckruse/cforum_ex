defmodule Cforum.Vote do
  use Cforum.Web, :model

  schema "votes" do
    field :vtype, :string
    belongs_to :user, Cforum.User
    belongs_to :message, Cforum.Message

    timestamps()
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
