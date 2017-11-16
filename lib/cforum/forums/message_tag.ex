defmodule Cforum.Forums.MessageTag do
  use CforumWeb, :model

  @primary_key {:message_tag_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :message_tag_id}

  schema "messages_tags" do
    belongs_to(:message, Cforum.Forums.Message, references: :message_id)
    belongs_to(:tag, Cforum.Forums.Tag, references: :tag_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:message_id, :tag_id])
    |> validate_required([:message_id, :tag_id])
  end
end
