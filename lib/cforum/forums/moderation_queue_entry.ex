defmodule Cforum.Forums.ModerationQueueEntry do
  use CforumWeb, :model

  @primary_key {:moderation_queue_entry_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :moderation_queue_entry_id}

  @reasons ~w[off-topic not-constructive illegal duplicate spam custom]
  def reasons(), do: @reasons

  schema "moderation_queue" do
    field(:cleared, :boolean, default: false)
    field(:reported, :integer, default: 1)
    field(:reason, :string)
    field(:duplicate_url, :string)
    field(:custom_reason, :string)
    field(:resolution, :string)
    field(:resolution_action, :string)
    field(:closer_name, :string)

    belongs_to(:message, Cforum.Forums.Message, references: :message_id)
    belongs_to(:closer, Cforum.Accounts.User, references: :user_id)

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `attrs`.
  """
  def create_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:reported, :reason, :duplicate_url, :custom_reason, :message_id])
    |> validate_required([:reason, :message_id])
    |> maybe_require_others()
    |> validate_inclusion(:reason, @reasons)
    |> unique_constraint(:message_id, name: :moderation_queue_message_id_idx)
  end

  defp maybe_require_others(changeset) do
    case get_field(changeset, :reason) do
      "duplicate" -> validate_required(changeset, [:duplicate_url])
      "custom" -> validate_required(changeset, [:custom_reason])
      _ -> changeset
    end
  end
end
