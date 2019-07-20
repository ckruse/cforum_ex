defmodule Cforum.Messages.Tags do
  @moduledoc """
  The boundary for the Forums system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Messages.Tag
  alias Cforum.Messages.TagSynonym
  alias Cforum.System

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  @spec list_tags() :: [%Tag{}]
  def list_tags() do
    from(tag in Tag, order_by: [asc: :tag_name], preload: [:synonyms])
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
  @spec get_tag!(String.t() | integer()) :: %Tag{}
  def get_tag!(id) do
    Tag
    |> Repo.get!(id)
    |> Repo.preload([:synonyms])
  end

  @doc """
  Gets a single tag by its slug.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag_by_slug!("rebellion")
      %Tag{}

      iex> get_tag!("imperium")
      ** (Ecto.NoResultsError)
  """
  @spec get_tag_by_slug!(String.t()) :: %Tag{}
  def get_tag_by_slug!(slug) do
    Tag
    |> Repo.get_by!(slug: slug)
    |> Repo.preload([:synonyms])
  end

  @doc """
  Gets a list of tags identified by tag name.

  ## Arguments

  - `tags`: a list of tag names

  ## Examples

  iex> get_tags(["menschelei", "zu diesem forum"])
  [%Tag{}, %Tag{}]

  """
  @spec get_tags([String.t()]) :: [%Tag{}]
  def get_tags(tags) do
    tags = Enum.map(tags, &String.downcase(&1))

    from(
      tag in Tag,
      left_join: syn in assoc(tag, :synonyms),
      where: fragment("lower(?)", tag.tag_name) in ^tags or fragment("lower(?)", syn.synonym) in ^tags,
      order_by: [desc: :tag_name]
    )
    |> Repo.all()
    |> Repo.preload([:synonyms])
  end

  @doc """
  Gets a list of tags identified by their `tag_id`

  ## Arguments

  - `tag_ids`: a list of tag IDs

  ## Examples

  iex> get_tags_by_tag_ids([1, 2, -1])
  [%Tag{}, %Tag{}]

  """
  @spec get_tags_by_ids([String.t() | integer()]) :: %Tag{}
  def get_tags_by_ids(tag_ids) do
    from(
      tag in Tag,
      where: tag.tag_id in ^tag_ids,
      order_by: [asc: :tag_name]
    )
    |> Repo.all()
    |> Repo.preload([:synonyms])
  end

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_tag(%Cforum.Accounts.User{}, map()) :: {:ok, %Tag{}} | {:error, Ecto.Changeset.t()}
  def create_tag(current_user, attrs \\ %{}) do
    System.audited("create", current_user, fn ->
      %Tag{}
      |> Tag.changeset(attrs)
      |> Repo.insert()
    end)
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_tag(%Cforum.Accounts.User{}, %Tag{}, map()) :: {:ok, %Tag{}} | {:error, Ecto.Changeset.t()}
  def update_tag(current_user, %Tag{} = tag, attrs) do
    System.audited("update", current_user, fn ->
      tag
      |> Tag.changeset(attrs)
      |> Repo.update()
    end)
  end

  @doc """
  Deletes a Tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_tag(%Cforum.Accounts.User{}, %Tag{}) :: {:ok, %Tag{}}
  def delete_tag(current_user, %Tag{} = tag) do
    System.audited("destroy", current_user, fn ->
      Repo.delete(tag)
    end)
  end

  @doc """
  Merges two tags so that all messages with belong to the tag
  `old_tag` now belong to the tag `new_tag`. It also adds the old tag
  as a synonym to the new tag.

  ## Examples

      iex> merge_tag(%Tag{}, %Tag{})
      {:ok, %Tag{}}

  """
  @spec merge_tag(%Cforum.Accounts.User{}, %Tag{}, %Tag{}) :: {:ok, %Tag{}} | {:error, Ecto.Changeset.t()}
  def merge_tag(current_user, %Tag{} = old_tag, %Tag{} = new_tag) do
    System.audited("merge", current_user, fn ->
      from(mtag in "messages_tags", where: mtag.tag_id == ^old_tag.tag_id)
      |> Repo.update_all(set: [tag_id: new_tag.tag_id])

      from(syn in TagSynonym, where: syn.tag_id == ^old_tag.tag_id)
      |> Repo.update_all(set: [tag_id: new_tag.tag_id])

      with {:ok, %TagSynonym{}} <- create_tag_synonym(current_user, new_tag, %{synonym: old_tag.tag_name}),
           {:ok, %Tag{}} <- Repo.delete(old_tag),
           tag = %Tag{} = get_tag!(new_tag.tag_id) do
        {:ok, tag}
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
  @spec change_tag(%Tag{}) :: Ecto.Changeset.t()
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end

  @doc """
  Returns the list of tag synonyms for a tag.

  ## Examples

      iex> list_tag_synonyms(%Tag{})
      [%TagSynonym{}, ...]

  """
  def list_tag_synonyms(tag) do
    case tag.synonyms do
      %Ecto.Association.NotLoaded{} ->
        from(tag_synonym in TagSynonym, where: tag_synonym.tag_id == ^tag.tag_id)
        |> Repo.all()

      synonyms ->
        synonyms
    end
  end

  @doc """
  Gets a single tag synonym of a tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag_synonym!(%Tag{}, 123)
      %TagSynonym{}

      iex> get_tag!(%Tag{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_tag_synonym!(%Tag{} = tag, id), do: Repo.get_by!(TagSynonym, tag_synonym_id: id, tag_id: tag.tag_id)

  @doc """
  Creates a tag synonym for the given `tag`.

  ## Examples

      iex> create_tag_synonym(%Tag{}, %{synonym: value})
      {:ok, %TagSynonym{}}

      iex> create_tag(%Tag{}, %{synonym: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_tag_synonym(current_user, %Tag{} = tag, attrs \\ %{}) do
    System.audited("create", current_user, fn ->
      %TagSynonym{}
      |> TagSynonym.changeset(tag, attrs)
      |> Repo.insert()
    end)
  end

  @doc """
  Updates a tag synonym.

  ## Examples

      iex> update_tag_synonym(%Tag{}, synonym, %{field: new_value})
      {:ok, %TagSynonym{}}

      iex> update_tag_synonym(%Tag{}, synonym, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag_synonym(current_user, %Tag{} = tag, %TagSynonym{} = synonym, attrs) do
    System.audited("update", current_user, fn ->
      synonym
      |> TagSynonym.changeset(tag, attrs)
      |> Repo.update()
    end)
  end

  @doc """
  Deletes a Tag synonym.

  ## Examples

      iex> delete_tag_synonym(synonym)
      {:ok, %TagSynonym{}}

      iex> delete_tag_synonym(synonym)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag_synonym(current_user, %TagSynonym{} = synonym) do
    System.audited("destroy", current_user, fn ->
      Repo.delete(synonym)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag synonym changes.

  ## Examples

      iex> change_tag_synonym(%Tag{}, synonym)
      %Ecto.Changeset{source: %TagSynonym{}}

  """
  def change_tag_synonym(%Tag{} = tag, %TagSynonym{} = synonym) do
    TagSynonym.changeset(synonym, tag, %{})
  end
end
