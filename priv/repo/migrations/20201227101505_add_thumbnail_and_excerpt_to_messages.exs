defmodule Cforum.Repo.Migrations.AddThumbnailAndExcerptToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add(:thumbnail, :string)
      add(:excerpt, :text)
    end
  end
end
