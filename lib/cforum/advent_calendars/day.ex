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
    |> maybe_put_author()
    |> validate_required([:date, :subject, :author, :content])
  end

  defp maybe_put_author(changeset) do
    case get_field(changeset, :user_id) do
      nil ->
        changeset

      id ->
        user = Cforum.Accounts.Users.get_user!(id)
        put_change(changeset, :author, user.username)
    end
  end
end
