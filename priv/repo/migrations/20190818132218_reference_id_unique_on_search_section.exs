defmodule Cforum.Repo.Migrations.ReferenceIdUniqueOnSearchSection do
  use Ecto.Migration

  def change do
    drop(constraint(:search_documents, :search_documents_reference_id_key))
    create(unique_index(:search_documents, [:reference_id, :search_section_id]))
  end
end
