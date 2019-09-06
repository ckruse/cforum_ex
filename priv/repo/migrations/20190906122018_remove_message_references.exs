defmodule Cforum.Repo.Migrations.RemoveMessageReferences do
  use Ecto.Migration

  def up do
    drop(table(:message_references))
  end
end
