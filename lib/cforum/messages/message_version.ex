defmodule Cforum.Messages.MessageVersion do
  use CforumWeb, :model

  @primary_key {:message_version_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :message_version_id}

  @type t() :: %__MODULE__{}

  schema "message_versions" do
    field(:author, :string)
    field(:subject, :string)
    field(:content, :string)

    belongs_to(:message, Cforum.Messages.Message, references: :message_id)
    belongs_to(:user, Cforum.Users.User, references: :user_id)

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  def changeset(struct, message, user \\ nil) do
    struct
    |> cast(Map.from_struct(message), [:subject, :content])
    |> put_change(:message_id, message.message_id)
    |> put_change(:subject, message.subject)
    |> put_change(:content, message.content)
    |> put_user_info(message, user)
  end

  def put_user_info(changeset, message, nil),
    do: put_change(changeset, :author, message.author)

  def put_user_info(changeset, _, user) do
    changeset
    |> put_change(:author, user.username)
    |> put_change(:user_id, user.user_id)
  end
end
