defmodule Cforum.AdventCalendars.Day do
  use Ecto.Schema
  import Ecto.Changeset

  schema "advent_calendar_days" do
    field(:date, :date)
    field(:subject, :string)
    field(:author, :string)
    field(:link, :string)
    field(:content, :string)

    belongs_to(:user, Cforum.Accounts.User, references: :user_id)

    timestamps()
  end

  @doc false
  def changeset(day, attrs) do
    day
    |> cast(attrs, [:date, :subject, :author, :user_id, :link, :content])
    |> validate_required([:date, :subject, :author, :content])
  end
end
