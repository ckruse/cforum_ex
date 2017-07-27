defmodule Cforum.Forums.ReadMessage do
  use CforumWeb, :model

  @primary_key {:read_message_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :read_message_id}

  schema "read_messages" do
    belongs_to :user, Cforum.Accounts.User, references: :user_id
    belongs_to :message, Cforum.Forums.Message, references: :message_id
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
