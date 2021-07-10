defmodule Cforum.Repo.Migrations.AddDraftToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add(:draft, :boolean, null: false, default: false)
    end
  end
end
