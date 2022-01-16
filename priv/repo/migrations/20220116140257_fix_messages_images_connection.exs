defmodule Cforum.Repo.Migrations.FixMessagesImagesConnection do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE messages_media DROP CONSTRAINT messages_media_medium_id_fkey")

    alter table(:messages_media) do
      modify(:medium_id, references(:media, column: :medium_id, on_delete: :delete_all, on_update: :update_all))
    end
  end

  def down do
    execute("ALTER TABLE messages_media DROP CONSTRAINT messages_media_medium_id_fkey")

    alter table(:messages_media) do
      modify(:medium_id, references(:media, column: :medium_id, on_delete: :restrict, on_update: :update_all))
    end
  end
end
