defmodule Cforum.Repo.Migrations.AddInactivityNotification do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:inactivity_notification_sent_at, :naive_datetime)
    end
  end
end
