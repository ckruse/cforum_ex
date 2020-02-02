defmodule Cforum.Repo.Migrations.UpgradeObanV8 do
  use Ecto.Migration

  def up do
    Oban.Migrations.up()
  end

  def down do
    Oban.Migrations.down(version: 8)
  end
end
