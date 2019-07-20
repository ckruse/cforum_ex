defmodule Cforum.Cites.Cite do
  use CforumWeb, :model

  alias Cforum.Messages

  @primary_key {:cite_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :cite_id}

  schema "cites" do
    field(:archived, :boolean, default: false)
    field(:author, :string)
    field(:cite, :string)
    field(:cite_date, :utc_datetime)
    field(:creator, :string)
    field(:old_id, :integer)
    field(:url, :string)

    belongs_to(:user, Cforum.Accounts.User, references: :user_id)
    belongs_to(:message, Cforum.Messages.Message, references: :message_id)
    belongs_to(:creator_user, Cforum.Accounts.User, references: :user_id)

    has_many(:votes, Cforum.Cites.Vote, foreign_key: :cite_id)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(cite, attrs, current_user \\ nil) do
    cite
    |> cast(attrs, [:url, :author, :user_id, :cite, :creator, :creator_user_id])
    |> maybe_set_message_and_user_id()
    |> maybe_set_creator(current_user)
    |> set_cite_date()
    |> validate_required([:cite, :author, :creator, :url])
    |> Cforum.Helpers.validate_url(:url)
  end

  def json_changeset(cite, attrs) do
    cast(cite, attrs, [
      :archived,
      :author,
      :cite,
      :cite_date,
      :creator,
      :old_id,
      :url,
      :user_id,
      :message_id,
      :creator_user_id,
      :created_at,
      :updated_at
    ])
  end

  defp maybe_set_message_and_user_id(%Ecto.Changeset{valid?: true} = changeset) do
    url = get_change(changeset, :url) || ""
    base_url = Application.get_env(:cforum, :base_url)

    part = String.slice(url, 0..(String.length(base_url) - 1))
    matchdata = Regex.run(~r</[\w0-9_-]+(/\d{4,}/[a-z]{3}/\d{1,2}/[^/]+)/(\d+)>, url)

    if part == base_url && matchdata do
      mid = List.last(matchdata)
      message = Messages.get_message(mid)
      set_message_and_user_id(changeset, message)
    else
      changeset
    end
  end

  defp maybe_set_message_and_user_id(changeset), do: changeset

  defp set_message_and_user_id(changeset, nil), do: changeset

  defp set_message_and_user_id(changeset, message) do
    changeset
    |> put_change(:author, message.author)
    |> put_change(:user_id, message.user_id)
    |> put_change(:message_id, message.message_id)
    |> put_change(:cite_date, message.created_at)
  end

  defp maybe_set_creator(changeset, nil), do: changeset

  defp maybe_set_creator(changeset, user) do
    changeset
    |> put_change(:creator_user_id, user.user_id)
    |> put_change(:creator, user.username)
  end

  defp set_cite_date(%Ecto.Changeset{valid?: true} = changeset) do
    case get_field(changeset, :cite_date) do
      nil ->
        put_change(changeset, :cite_date, DateTime.truncate(Timex.now(), :second))

      _ ->
        changeset
    end
  end

  defp set_cite_date(changeset), do: changeset
end
