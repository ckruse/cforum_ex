defmodule Cforum.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:event_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :event_id}

  schema "events" do
    field(:name, :string)
    field(:description, :string)
    field(:start_date, :date)
    field(:end_date, :date)
    field(:location, :string)
    field(:maps_link, :string)
    field(:visible, :boolean, default: false)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :description, :location, :maps_link, :start_date, :end_date, :visible])
    |> validate_required([:name, :description, :location, :start_date, :end_date, :visible])
    |> unique_constraint(:name, name: :events_lower_idx)
  end
end
