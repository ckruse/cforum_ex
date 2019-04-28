defmodule Cforum.Messages.CloseVote do
  use CforumWeb, :model

  @primary_key {:close_vote_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :close_vote_id}

  @reasons ~w(off-topic not-constructive illegal duplicate spam custom)
  def reasons(), do: @reasons

  schema "close_votes" do
    field(:reason, :string)
    field(:duplicate_slug, :string)
    field(:custom_reason, :string)
    field(:finished, :boolean, default: false)
    field(:vote_type, :boolean, default: false)

    belongs_to(:message, Cforum.Messages.Message, references: :message_id)

    has_many(:voters, Cforum.Messages.CloseVoteVoter, references: :close_vote_id, foreign_key: :close_vote_id)

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def new_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:reason, :duplicate_slug, :custom_reason])
    |> put_change(:vote_type, false)
    |> validate_required([:reason])
    |> maybe_require_others()
    |> validate_inclusion(:reason, @reasons)
    |> unique_constraint(:message_id, name: :close_votes_message_id_vote_type_key)
  end

  def new_open_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:custom_reason])
    |> put_change(:vote_type, true)
    |> put_change(:reason, "custom")
    |> validate_required([:custom_reason])
    |> unique_constraint(:message_id, name: :close_votes_message_id_vote_type_key)
  end

  def finish_changeset(struct) do
    struct
    |> cast(%{finished: true}, [:finished])
  end

  defp maybe_require_others(changeset) do
    case get_field(changeset, :reason) do
      "duplicate" -> validate_required(changeset, [:duplicate_url])
      "custom" -> validate_required(changeset, [:custom_reason])
      _ -> changeset
    end
  end
end
