defmodule Cforum.Forums do
  @moduledoc """
  The boundary for the Forums system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Forums.Forum
  alias Cforum.System
  alias Cforum.Users.User
  alias Cforum.Settings
  alias Cforum.Caching
  alias Cforum.Groups
  use Cforum.Constants

  @spec discard_forums_cache({:ok, any()} | any()) :: {:ok, any()} | any()
  def discard_forums_cache({:ok, rel}) do
    Caching.del(:cforum, "forums")
    {:ok, rel}
  end

  def discard_forums_cache(val), do: val

  @doc """
  Returns the list of forums.

  ## Examples

      iex> list_forums()
      [%Forum{}, ...]

  """
  @spec list_forums() :: [Forum.t()]
  def list_forums do
    Caching.fetch(:cforum, "forums", fn ->
      Forum
      |> ordered
      |> Repo.all()
    end)
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
  @spec get_forum!(String.t() | integer()) :: %Forum{}
  def get_forum!(id) do
    with {:ok, id} <- Ecto.Type.cast(:integer, id),
         %Forum{} = forum <- Enum.find(list_forums(), &(&1.forum_id == id)) do
      %Forum{forum | setting: Settings.get_setting_for_forum(forum)}
    else
      _ -> raise Ecto.NoResultsError, queryable: Forum
    end
  end

  @doc """
  Gets a single forum by its slug.

  Raises `Ecto.NoResultsError` if the Forum does not exist.

  ## Examples

      iex> get_forum_by_slug!("rebellion")
      %Forum{}

      iex> get_forum_by_slug!("aldebaran")
      ** (Ecto.NoResultsError)

  """
  @spec get_forum_by_slug!(String.t()) :: Forum.t()
  def get_forum_by_slug!(slug) do
    with %Forum{} = forum <- Enum.find(list_forums(), &(&1.slug == slug)) do
      %Forum{forum | setting: Settings.get_setting_for_forum(forum)}
    else
      _ -> raise Ecto.NoResultsError, queryable: Forum
    end
  end

  @spec get_forum_by_slug(String.t()) :: Forum.t() | nil
  def get_forum_by_slug(slug) do
    with %Forum{} = forum <- Enum.find(list_forums(), &(&1.slug == slug)) do
      %Forum{forum | setting: Settings.get_setting_for_forum(forum)}
    end
  end

  @spec get_forum_by_type(String.t()) :: Forum.t() | nil
  def get_forum_by_type(type) do
    with %Forum{} = forum <- Enum.find(list_forums(), &(&1.type == type)) do
      %Forum{forum | setting: Settings.get_setting_for_forum(forum)}
    end
  end

  @doc """
  Creates a forum.

  ## Examples

      iex> create_forum(%{field: value})
      {:ok, %Forum{}}

      iex> create_forum(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_forum(User.t() | nil, map()) :: {:ok, Forum.t()} | {:error, Ecto.Changeset.t()}
  def create_forum(current_user, attrs \\ %{}) do
    System.audited("create", current_user, fn ->
      %Forum{}
      |> Forum.changeset(attrs)
      |> Repo.insert()
    end)
    |> Settings.discard_settings_cache()
    |> discard_forums_cache()
  end

  @doc """
  Updates a forum.

  ## Examples

      iex> update_forum(forum, %{field: new_value})
      {:ok, %Forum{}}

      iex> update_forum(forum, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_forum(User.t() | nil, Forum.t(), map()) :: {:ok, Forum.t()} | {:error, Ecto.Changeset.t()}
  def update_forum(current_user, %Forum{} = forum, attrs) do
    System.audited("update", current_user, fn ->
      forum
      |> Forum.changeset(attrs)
      |> Repo.update()
    end)
    |> Settings.discard_settings_cache()
    |> discard_forums_cache()
  end

  @doc """
  Deletes a Forum.

  ## Examples

      iex> delete_forum(forum)
      {:ok, %Forum{}}

      iex> delete_forum(forum)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_forum(User.t() | nil, Forum.t()) :: {:ok, Forum.t()} | {:error, Ecto.Changeset.t()}
  def delete_forum(current_user, %Forum{} = forum) do
    System.audited("destroy", current_user, fn ->
      Repo.delete(forum)
    end)
    |> Settings.discard_settings_cache()
    |> discard_forums_cache()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking forum changes.

  ## Examples

      iex> change_forum(forum)
      %Ecto.Changeset{source: %Forum{}}

  """
  @spec change_forum(Forum.t()) :: Ecto.Changeset.t()
  def change_forum(%Forum{} = forum) do
    Forum.changeset(forum, %{})
  end

  @doc """
  Returns an ordered list of %Forum{} visible to the given user

  ## Examples

      iex> list_visible_forums(user)
      [%Forum{}]

  """
  @spec list_visible_forums(nil | User.t()) :: [Forum.t()]
  def list_visible_forums(user \\ nil) do
    list_forums()
    |> visible_forums(user)
  end

  defp visible_forums(forums, nil) do
    Enum.filter(forums, &(&1.standard_permission in [@permission_read, @permission_write, @permission_answer]))
  end

  # admins may view all forums
  defp visible_forums(forums, %User{admin: true}), do: forums

  defp visible_forums(forums, %User{} = user) do
    permissions = [
      @permission_read,
      @permission_write,
      @permission_answer,
      @permission_known_read,
      @permission_known_write
    ]

    Enum.filter(forums, &(&1.standard_permission in permissions || Groups.permission?(user, &1, permissions)))
  end

  defp ordered(query) do
    query |> order_by([n], asc: n.position)
  end

  @doc """
  Returns an ordered list of %Forum{} the user has the specified permission to

  ## Examples

      iex> list_forums_by_permission(%User{}, "read)
      [%Forum{}]

  """
  @spec list_forums_by_permission(User.t() | nil, String.t()) :: [Forum.t()]
  def list_forums_by_permission(user, permission)

  def list_forums_by_permission(nil, permission) when permission in ~w(read write answer) do
    plist =
      case permission do
        "write" -> [@permission_write]
        "answer" -> [@permission_write, @permission_answer]
        _ -> [@permission_write, @permission_read, @permission_answer]
      end

    list_forums()
    |> Enum.filter(&(&1.standard_permission in plist))
  end

  def list_forums_by_permission(%User{admin: true}, _), do: list_forums()

  def list_forums_by_permission(%User{} = user, "moderate"),
    do: list_forums_by_perms(user, ~w(moderate), [])

  def list_forums_by_permission(%User{} = user, "write"),
    do: list_forums_by_perms(user, ~w(moderate write), ~w(known-write write))

  def list_forums_by_permission(%User{} = user, "read"),
    do: list_forums_by_perms(user, ~w(moderate write read), ~w(known-write write known-read read))

  defp list_forums_by_perms(%User{} = user, permissions, std_permissions) do
    list_forums()
    |> Enum.filter(&(&1.standard_permission in std_permissions || Groups.permission?(user, &1, permissions)))
  end
end
