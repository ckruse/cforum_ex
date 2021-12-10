defmodule Cforum.Repo.Migrations.AddAltToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add(:thumbnail_alt, :string)
    end
  end
end
