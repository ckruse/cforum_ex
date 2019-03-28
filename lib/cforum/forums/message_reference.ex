defmodule Cforum.Forums.MessageReference do
  use CforumWeb, :model

  import Ecto.Query, warn: false

  @primary_key {:message_reference_id, :id, autogenerate: true}

  schema "message_references" do
    belongs_to(:src_message, Cforum.Forums.Message, references: :message_id)
    belongs_to(:dst_message, Cforum.Forums.Message, references: :message_id)

    timestamps(inserted_at: :created_at)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:src_message_id, :dst_message_id])
    |> validate_required([:src_message_id, :dst_message_id])
  end
end
