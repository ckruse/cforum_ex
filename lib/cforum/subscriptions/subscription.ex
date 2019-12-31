defmodule Cforum.Subscriptions.Subscription do
  use CforumWeb, :model

  @primary_key {:subscription_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :subscription_id}

  schema "subscriptions" do
    field(:user_id, :id)
    field(:message_id, :id)
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
