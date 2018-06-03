defmodule Cforum.Events.Attendee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:attendee_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :attendee_id}

  schema "attendees" do
    field(:name, :string)
    field(:comment, :string)
    field(:starts_at, :string)
    field(:planned_start, Timex.Ecto.DateTime)
    field(:planned_arrival, Timex.Ecto.DateTime)
    field(:planned_leave, Timex.Ecto.DateTime)
    field(:seats, :integer)

    belongs_to(:event, Cforum.Events.Event, references: :event_id)
    belongs_to(:user, Cforum.Accounts.User, references: :user_id)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :comment, :starts_at, :planned_start, :planned_arrival, :planned_leave, :seats])
    |> validate_required([:name])
    |> unique_constraint(:user_id, name: :attendees_event_id_user_id_key)
  end
end
