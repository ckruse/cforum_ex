defmodule Cforum.Repo.Migrations.DropOpenCloseVotes do
  use Ecto.Migration

  def change do
    drop(table(:close_votes_voters))
    drop(table(:close_votes))
    execute("DELETE FROM badges WHERE slug = 'visit_close_reopen'")
    execute("DELETE FROM badges WHERE slug = 'create_close_reopen_vote'")
  end
end
