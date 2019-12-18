defmodule Cforum.Repo.Migrations.CreateAdventCalendarDays do
  use Ecto.Migration

  def change do
    create table(:advent_calendar_days) do
      add(:date, :date, null: false)
      add(:subject, :string, null: false)
      add(:author, :string, null: false)
      add(:user_id, references(:users, column: :user_id, on_delete: :nilify_all))
      add(:link, :string)
      add(:content, :text)

      timestamps()
    end

    create(unique_index(:advent_calendar_days, [:date]))
  end
end
