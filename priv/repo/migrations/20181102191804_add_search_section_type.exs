defmodule Cforum.Repo.Migrations.AddSearchSectionType do
  use Ecto.Migration

  def change do
    alter(table(:search_sections), do: add(:section_type, :string))
  end
end
