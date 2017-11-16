defmodule Cforum.Accounts.PrivMessage do
  use CforumWeb, :model

  @primary_key {:priv_message_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :priv_message_id}

  schema "priv_messages" do
    belongs_to(:sender, Cforum.Accounts.User, references: :user_id)
    belongs_to(:recipient, Cforum.Accounts.User, references: :user_id)
    belongs_to(:owner, Cforum.Accounts.User, references: :user_id)

    field(:is_read, :boolean, default: false)
    field(:subject, :string)
    field(:body, :string)
    field(:sender_name, :string)
    field(:recipient_name, :string)
    field(:thread_id, :integer)

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
         :sender_id,
         :recipient_id,
         :owner_id,
         :is_read,
         :subject,
         :body,
         :sender_name,
         :recipient_name,
         :thread_id
       ])
    |> validate_required([:owner_id, :is_read, :subject, :body, :sender_name, :recipient_name])
  end
end
