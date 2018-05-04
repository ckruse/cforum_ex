defmodule Cforum.Forums.Tags do
  @moduledoc """
  The boundary for the Forums system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Forums.Tag
  alias Cforum.Forums.TagSynonym

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags(forum_or_nil, visible_forums)

  def list_tags(nil, visible_forums) do
    forum_ids = Enum.map(visible_forums, & &1.forum_id)

    from(tag in Tag, where: tag.forum_id in ^forum_ids, order_by: [asc: :tag_name])
    |> Repo.all()
  end

  def list_tags(forum, _) do
    from(tag in Tag, where: tag.forum_id == ^forum.forum_id, order_by: [asc: :tag_name])
    |> Repo.all()
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id) do
    Tag
    |> Repo.get!(id)
    |> Repo.preload([:synonyms])
  end

  def get_tag_by_slug!(forum, slug) do
    Tag
    |> Repo.get_by!(forum_id: forum.forum_id, slug: slug)
    |> Repo.preload([:synonyms])
  end

  def get_tags(tags, %Cforum.Forums.Forum{} = forum), do: get_tags(tags, forum.forum_id)

  def get_tags(tags, forum_id) do
    from(
      tag in Tag,
      left_join: syn in assoc(tag, :synonyms),
      where:
        (fragment("lower(?)", tag.tag_name) in ^tags or fragment("lower(?)", syn.synonym) in ^tags) and
          tag.forum_id == ^forum_id,
      order_by: [desc: :tag_name]
    )
    |> Repo.all()
  end

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(forum, attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(forum, attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(nil, attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  def merge_tag(old_tag, new_tag) do
    Repo.transaction(fn ->
      from(mtag in "messages_tags", where: mtag.tag_id == ^old_tag.tag_id)
      |> Repo.update_all(set: [tag_id: new_tag.tag_id])

      from(syn in TagSynonym, where: syn.tag_id == ^old_tag.tag_id)
      |> Repo.update_all(set: [tag_id: new_tag.tag_id])

      with {:ok, %TagSynonym{}} <- create_tag_synonym(new_tag, %{synonym: old_tag.tag_name}),
           {:ok, %Tag{}} <- delete_tag(old_tag),
           tag = %Tag{} = get_tag!(new_tag.tag_id) do
        tag
      else
        _ ->
          Repo.rollback(nil)
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{source: %Tag{}}

  """
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, nil, %{})
  end

  def get_tag_synonym!(%Tag{} = tag, id), do: Repo.get_by!(TagSynonym, tag_synonym_id: id, tag_id: tag.tag_id)

  def create_tag_synonym(%Tag{} = tag, attrs \\ %{}) do
    %TagSynonym{}
    |> TagSynonym.changeset(tag, attrs)
    |> Repo.insert()
  end

  def update_tag_synonym(%Tag{} = tag, %TagSynonym{} = synonym, attrs) do
    synonym
    |> TagSynonym.changeset(tag, attrs)
    |> Repo.update()
  end

  def delete_tag_synonym(synonym) do
    Repo.delete(synonym)
  end

  def change_synonym(tag, %TagSynonym{} = synonym) do
    TagSynonym.changeset(synonym, tag, %{})
  end
end
