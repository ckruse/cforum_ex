defmodule Cforum.Accounts.PrivMessage do
  use CforumWeb, :model

  alias Ecto.Changeset

  @primary_key {:priv_message_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :priv_message_id}
  @derive {Jason.Encoder,
           only: [
             :is_read,
             :subject,
             :body,
             :sender_name,
             :recipient_name,
             :thread_id,
             :sender,
             :recipient,
             :created_at,
             :updated_at
           ]}

  schema "priv_messages" do
    field(:is_read, :boolean, default: false)
    field(:subject, :string)
    field(:body, :string)
    field(:sender_name, :string)
    field(:recipient_name, :string)
    field(:thread_id, :integer)

    belongs_to(:sender, Cforum.Accounts.User, references: :user_id)
    belongs_to(:recipient, Cforum.Accounts.User, references: :user_id)
    belongs_to(:owner, Cforum.Accounts.User, references: :user_id)

    has_many(:messages, Cforum.Accounts.PrivMessage, references: :thread_id, foreign_key: :thread_id)

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}, sender \\ nil, set_owner_to_sender \\ false) do
    struct
    |> cast(params, [:recipient_id, :subject, :body, :thread_id])
    |> validate_required([:recipient_id, :subject, :body])
    |> maybe_set_sender_id(sender)
    |> set_name(:sender_id, :sender_name)
    |> set_name(:recipient_id, :recipient_name)
    |> set_owner_id(sender, set_owner_to_sender)
    |> validate_required([:owner_id])
  end

  def mark_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:is_read])
    |> validate_required([:is_read])
  end

  defp set_name(%Changeset{valid?: false} = changeset, _id_attr, _name_attr), do: changeset

  defp set_name(changeset, id_attr, name_attr) do
    case Changeset.get_field(changeset, id_attr) do
      nil ->
        add_error(changeset, id_attr, "empty")

      id ->
        user = Cforum.Accounts.Users.get_user!(id)
        put_change(changeset, name_attr, user.username)
    end
  end

  defp set_owner_id(%Changeset{valid?: false} = changeset, _, _), do: changeset
  defp set_owner_id(changeset, nil, true), do: changeset
  defp set_owner_id(changeset, user, true), do: put_change(changeset, :owner_id, user.user_id)
  defp set_owner_id(changeset, _, false), do: put_change(changeset, :owner_id, get_field(changeset, :recipient_id))

  defp maybe_set_sender_id(changeset, %Cforum.Accounts.User{} = user),
    do: Changeset.put_change(changeset, :sender_id, user.user_id)

  defp maybe_set_sender_id(changeset, _), do: changeset
end
