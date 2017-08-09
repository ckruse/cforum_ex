defmodule Cforum.Forums do
  @moduledoc """
  The boundary for the Forums system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Forums.Forum

  @doc """
  Returns the list of forums.

  ## Examples

      iex> list_forums()
      [%Forum{}, ...]

  """
  def list_forums do
    Forum
    |> ordered
    |> Repo.all
  end

  @doc """
  Gets a single forum.

  Raises `Ecto.NoResultsError` if the Forum does not exist.

  ## Examples

      iex> get_forum!(123)
      %Forum{}

      iex> get_forum!(456)
      ** (Ecto.NoResultsError)

  """
  def get_forum!(id), do: Repo.get!(Forum, id)

  @doc """
  Gets a single forum by its slug.

  Raises `Ecto.NoResultsError` if the Forum does not exist.

  ## Examples

      iex> get_forum_by_slug!("rebellion")
      %Forum{}

      iex> get_forum_by_slug!("aldebaran")
      ** (Ecto.NoResultsError)

  """
  def get_forum_by_slug!(slug), do: Repo.get_by!(Forum, slug: slug)

  @doc """
  Creates a forum.

  ## Examples

      iex> create_forum(%{field: value})
      {:ok, %Forum{}}

      iex> create_forum(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_forum(attrs \\ %{}) do
    %Forum{}
    |> Forum.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a forum.

  ## Examples

      iex> update_forum(forum, %{field: new_value})
      {:ok, %Forum{}}

      iex> update_forum(forum, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_forum(%Forum{} = forum, attrs) do
    forum
    |> Forum.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Forum.

  ## Examples

      iex> delete_forum(forum)
      {:ok, %Forum{}}

      iex> delete_forum(forum)
      {:error, %Ecto.Changeset{}}

  """
  def delete_forum(%Forum{} = forum) do
    Repo.delete(forum)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking forum changes.

  ## Examples

      iex> change_forum(forum)
      %Ecto.Changeset{source: %Forum{}}

  """
  def change_forum(%Forum{} = forum) do
    Forum.changeset(forum, %{})
  end

  @doc """
  Returns an ordered list of %Forum{} visible to the given user

  ## Examples

      iex> list_visible_forums(user)
      [%Forum{}]

  """
  def list_visible_forums(user \\ nil) do
    Forum
    |> visible_forums(user)
    |> ordered
    |> Repo.all
  end

  alias Cforum.Accounts.User

  defp visible_forums(query, nil) do
    from f in query,
      where: f.standard_permission in [^Forum.read, ^Forum.write]
  end
  defp visible_forums(query, %User{admin: true}) do # admins may view all forums
    query
  end
  defp visible_forums(query, %User{} = user) do
    from f in query,
      where: f.standard_permission in [^Forum.read, ^Forum.write, ^Forum.known_read, ^Forum.known_write] or
             fragment("? IN (SELECT forum_id FROM forums_groups_permissions INNER JOIN groups_users USING(group_id) WHERE user_id = ?)", f.forum_id, ^user.user_id)
  end

  defp ordered(query) do
    query |> order_by([n], asc: n.position)
  end
end
