defmodule Cforum.Forums.InterestingMessage do
  use Cforum.Web, :model

  @primary_key {:interesting_message_id, :integer, []}
  @derive {Phoenix.Param, key: :interesting_message_id}

  schema "interesting_messages" do
    belongs_to :user, Cforum.Accounts.User, references: :user_id
    belongs_to :message, Cforum.Forums.Message, references: :message_id

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :message_id])
    |> validate_required([:user_id, :message_id])
  end
end
