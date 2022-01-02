defmodule Cforum.Repo.Migrations.AddMessagesMedia do
  use Ecto.Migration

  def change do
    create table(:messages_media) do
      add(:message_id, references(:messages, column: :message_id, on_delete: :delete_all, on_update: :update_all))
      add(:medium_id, references(:media, column: :medium_id, on_delete: :restrict, on_update: :update_all))
    end

    create(index(:messages_media, [:message_id]))
    create(index(:messages_media, [:medium_id]))
  end
end
