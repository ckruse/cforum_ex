defmodule Cforum.Repo.Migrations.AddVisibleToForums do
  use Ecto.Migration

  def change do
    alter table(:forums) do
      add(:visible, :boolean, null: false, default: true)
    end
  end
end
