defmodule Cforum.Forums do
  @moduledoc """
  The boundary for the Forums system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Forums.Forum
  alias Cforum.System

  @doc """
  Returns the list of forums.

  ## Examples

      iex> list_forums()
      [%Forum{}, ...]

  """
  def list_forums do
    Forum
    |> ordered
    |> Repo.all()
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

  def get_forum_by_slug!(slug, :preload_setting) do
    Repo.get_by!(Forum, slug: slug)
    |> Repo.preload(:setting)
  end

  @doc """
  Creates a forum.

  ## Examples

      iex> create_forum(%{field: value})
      {:ok, %Forum{}}

      iex> create_forum(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_forum(current_user, attrs \\ %{}) do
    System.audited("create", current_user, fn ->
      %Forum{}
      |> Forum.changeset(attrs)
      |> Repo.insert()
    end)
  end

  @doc """
  Updates a forum.

  ## Examples

      iex> update_forum(forum, %{field: new_value})
      {:ok, %Forum{}}

      iex> update_forum(forum, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_forum(current_user, %Forum{} = forum, attrs) do
    System.audited("update", current_user, fn ->
      forum
      |> Forum.changeset(attrs)
      |> Repo.update()
    end)
  end

  @doc """
  Deletes a Forum.

  ## Examples

      iex> delete_forum(forum)
      {:ok, %Forum{}}

      iex> delete_forum(forum)
      {:error, %Ecto.Changeset{}}

  """
  def delete_forum(current_user, %Forum{} = forum) do
    System.audited("destroy", current_user, fn ->
      Repo.delete(forum)
    end)
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
    |> Repo.all()
  end

  alias Cforum.Accounts.User

  defp visible_forums(query, nil) do
    from(f in query, where: f.standard_permission in [^Forum.read(), ^Forum.write()])
  end

  # admins may view all forums
  defp visible_forums(query, %User{admin: true}) do
    query
  end

  defp visible_forums(query, %User{} = user) do
    from(
      f in query,
      where:
        f.standard_permission in [^Forum.read(), ^Forum.write(), ^Forum.known_read(), ^Forum.known_write()] or
          fragment(
            "? IN (SELECT forum_id FROM forums_groups_permissions INNER JOIN groups_users USING(group_id) WHERE user_id = ?)",
            f.forum_id,
            ^user.user_id
          )
    )
  end

  defp ordered(query) do
    query |> order_by([n], asc: n.position)
  end
end
