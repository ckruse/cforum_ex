alias Cforum.Repo
alias Cforum.Forums.TagSynonym

import Ecto.Query

defmodule Tag do
  use CforumWeb, :model

  alias Ecto.Changeset

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

    from(m in Cforum.Forums.MessageTag, where: m.tag_id in ^tag_ids)
    |> Repo.update_all(set: [tag_id: orig_tag.tag_id])

    from(m in Tag, where: m.tag_id in ^tag_ids)
    |> Repo.delete_all()
  end
end

Repo.transaction(fn ->
  tags =
    from(t in Tag, order_by: [asc: t.forum_id, asc: t.tag_id], preload: [:synonyms])
    |> Repo.all()
    |> Enum.reduce(%{}, fn tag, by_name -> Map.update(by_name, tag.tag_name, [tag], &(&1 ++ [tag])) end)
    |> Enum.filter(fn {_key, values} -> length(values) > 1 end)
    |> Enum.each(fn {_key, values} -> Tag.merge_tags(values) end)

  # next make synonyms unique
  synonyms =
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

  {:ok, nil}
end)
