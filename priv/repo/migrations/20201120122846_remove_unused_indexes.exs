defmodule Cforum.Repo.Migrations.RemoveUnusedIndexes do
  use Ecto.Migration

  def up do
    drop(index(:messages, [:mid], name: "messages_mid_idx"))
    drop(index(:messages, [:updated_at], name: "messages_updated_at_idx"))
    drop(index(:threads, [:sticky, :created_at], name: "threads_sticky_created_at_idx"))
    drop(index(:search_documents, [:title], name: "search_documents_title_idx"))
  end
end
