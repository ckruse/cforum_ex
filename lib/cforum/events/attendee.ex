defmodule Cforum.Events.Attendee do
  use CforumWeb, :model

  @primary_key {:attendee_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :attendee_id}

  schema "attendees" do
    field(:name, :string)
    field(:comment, :string)
    field(:starts_at, :string)
    field(:planned_start, :utc_datetime)
    field(:planned_arrival, :utc_datetime)
    field(:planned_leave, :utc_datetime)
    field(:seats, :integer)

    belongs_to(:event, Cforum.Events.Event, references: :event_id)
    belongs_to(:user, Cforum.Users.User, references: :user_id)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(event, attrs, user \\ nil) do
    event
    |> cast(attrs, [:name, :comment, :starts_at, :planned_start, :planned_arrival, :planned_leave, :seats])
    |> maybe_set_user(user)
    |> validate_required([:name, :planned_arrival])
    |> unique_constraint(:user_id, name: :attendees_event_id_user_id_key)
  end

  defp maybe_set_user(changeset, nil), do: changeset

  defp maybe_set_user(%Ecto.Changeset{valid?: true} = changeset, user) do
    changeset
    |> put_change(:name, user.username)
    |> put_change(:user_id, user.user_id)
  end

  defp maybe_set_user(changeset, _), do: changeset
end
