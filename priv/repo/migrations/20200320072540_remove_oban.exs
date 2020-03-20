defmodule Cforum.Repo.Migrations.RemoveOban do
  use Ecto.Migration

  def up do
    ObanWeb.Migrations.down()
  end

  def down do
  end
end
