defmodule Cforum.Repo.Migrations.AddActiveToForum do
  use Ecto.Migration

  def change do
    alter table(:forums) do
      add(:active, :boolean, null: false, default: true)
    end
  end
end
