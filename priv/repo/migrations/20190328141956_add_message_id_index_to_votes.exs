defmodule Cforum.Repo.Migrations.AddMessageIdIndexToVotes do
  use Ecto.Migration

  def change do
    create(index(:votes, [:message_id]))
  end
end
