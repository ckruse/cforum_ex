defmodule Cforum.Repo.Migrations.AddTypeToForums do
  use Ecto.Migration

  def change do
    alter table(:forums) do
      add(:type, :string, null: false, default: "forum")
    end
  end
end
