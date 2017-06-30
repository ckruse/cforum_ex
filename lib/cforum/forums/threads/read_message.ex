defmodule Cforum.Forums.Threads.ReadMessage do
  use Cforum.Web, :model

  @primary_key {:read_message_id, :integer, []}
  @derive {Phoenix.Param, key: :read_message_id}

  schema "read_messages" do
    belongs_to :user, Cforum.Accounts.User, references: :user_id
    belongs_to :message, Cforum.Forums.Threads.Message, references: :message_id
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
