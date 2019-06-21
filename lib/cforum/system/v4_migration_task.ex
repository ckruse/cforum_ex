defmodule Cforum.System.V4MigrationTaks do
  @moduledoc """
  Migration module to perform the necessary DB changes to get to the V5 schema
  """

  import Ecto.Query

  alias Cforum.Repo
  alias Cforum.Messages.TagSynonym
  alias Cforum.V4Tag

  def migrate do
    Repo.transaction(
      fn ->
        db_migrations()
        delete_archived_read_messages()
        merge_tags()
        {:ok, nil}
      end,
      timeout: :infinity
    )

    path = Application.app_dir(:cforum, "priv/repo/migrations")
    Ecto.Migrator.run(Cforum.Repo, path, :up, all: true)

    Repo.transaction(
      fn ->
        after_migration_changes()
        {:ok, nil}
      end,
      timeout: :infinity
    )
  end

  defp db_migrations do
    Repo.query!("""
      ALTER TABLE schema_migrations
        ALTER COLUMN version TYPE bigint USING version::bigint;
    """)

    Repo.query!("""
      ALTER TABLE schema_migrations
        ADD COLUMN inserted_at TIMESTAMP WITHOUT TIME ZONE;
    """)
  end

  defp delete_archived_read_messages do
    Repo.query!("""
      DELETE FROM read_messages
      WHERE EXISTS (
        SELECT messages.message_id
        FROM messages
        INNER JOIN threads USING(thread_id)
        WHERE messages.message_id = read_messages.message_id AND threads.archived = true
      )
    """)
  end

  defp merge_tags do
    from(t in V4Tag, order_by: [asc: t.forum_id, asc: t.tag_id], preload: [:synonyms])
    |> Repo.all()
    |> Enum.reduce(%{}, fn tag, by_name -> Map.update(by_name, tag.tag_name, [tag], &(&1 ++ [tag])) end)
    |> Enum.filter(fn {_key, values} -> length(values) > 1 end)
    |> Enum.each(fn {_key, values} -> V4Tag.merge_tags(values) end)

    # next make synonyms unique
    from(syn in TagSynonym,
      group_by: fragment("tag_id, lower(synonym)"),
      having: fragment("count(lower(synonym)) > 1"),
      select: {syn.tag_id, fragment("lower(synonym)")}
    )
    |> Repo.all()
    |> Enum.each(fn {tag_id, syn_val} ->
      from(syn in TagSynonym,
        where: syn.tag_id == ^tag_id and syn.synonym == ^syn_val,
        order_by: [asc: :tag_synonym_id],
        offset: 1
      )
      |> Repo.all()
      |> Enum.each(&Repo.delete/1)
    end)
  end

  defp after_migration_changes do
    Repo.query!("UPDATE search_sections SET section_type = 'forum' WHERE forum_id IS NOT NULL")
    Repo.query!("UPDATE search_sections SET section_type = 'cites' WHERE forum_id IS NULL")
  end
end

defmodule Cforum.V4Tag do
  use CforumWeb, :model

  import Ecto.Query

  alias Cforum.Repo
  alias Cforum.Messages.TagSynonym
  alias Cforum.V4Tag

  @primary_key {:tag_id, :id, autogenerate: true}

  schema "tags" do
    field(:tag_name, :string)
    field(:slug, :string)
    field(:num_messages, :integer)
    field(:suggest, :boolean)
    field(:forum_id, :id)

    has_many(:synonyms, TagSynonym, foreign_key: :tag_id)
  end

  def merge_tags(tags) do
    [orig_tag | rest] = tags

    unknown_synonyms =
      rest
      |> Enum.flat_map(& &1.synonyms)
      |> Enum.filter(fn synonym ->
        Enum.find(orig_tag.synonyms, &(&1.synonym != synonym.synonym)) == nil
      end)
      |> Enum.uniq_by(& &1.synonym)
      |> Enum.map(& &1.tag_synonym_id)

    if unknown_synonyms != [] do
      from(syn in TagSynonym, where: syn.tag_synonym_id in ^unknown_synonyms)
      |> Repo.update_all(set: [tag_id: orig_tag.tag_id])
    end

    tag_ids = Enum.map(rest, & &1.tag_id)

    from(m in Cforum.Messages.Tags.MessageTag, where: m.tag_id in ^tag_ids)
    |> Repo.update_all(set: [tag_id: orig_tag.tag_id])

    from(m in V4Tag, where: m.tag_id in ^tag_ids)
    |> Repo.delete_all()
  end
end
