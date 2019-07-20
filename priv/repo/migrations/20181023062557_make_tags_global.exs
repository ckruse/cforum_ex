defmodule Cforum.Repo.Migrations.MakeTagsGlobal do
  use Ecto.Migration

  def change do
    alter(table(:tags), do: remove(:forum_id))
    alter(table(:tag_synonyms), do: remove(:forum_id))
    create(unique_index(:tags, ["lower(tag_name)"]))
    create(unique_index(:tag_synonyms, ["lower(synonym)"]))
  end
end
