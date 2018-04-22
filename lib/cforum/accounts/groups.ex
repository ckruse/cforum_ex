defmodule Cforum.Accounts.Groups do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Accounts.Group
  alias Cforum.Accounts.ForumGroupPermission

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    from(group in Group, preload: [:users, :permissions], order_by: [desc: :name])
    |> Repo.all()
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id) do
    Group
    |> Repo.get!(id)
    |> Repo.preload([:permissions, :users])
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{source: %Group{}}

  """
  def change_group(%Group{} = group) do
    Group.changeset(group, %{})
  end

  def list_permissions_for_user_and_forum(user, forum) do
    from(
      fgp in ForumGroupPermission,
      where:
        fgp.group_id in fragment("SELECT group_id FROM groups_users WHERE user_id = ?", ^user.user_id) and
          fgp.forum_id == ^forum.forum_id
    )
    |> Repo.all()
  end

  def permission?(user, forum, permission) when is_bitstring(permission), do: permission?(user, forum, [permission])

  def permission?(user, forum, permission) when is_list(permission) do
    from(
      fgp in ForumGroupPermission,
      where:
        fgp.group_id in fragment("SELECT group_id FROM groups_users WHERE user_id = ?", ^user.user_id) and
          fgp.forum_id == ^forum.forum_id and fgp.permission in ^permission
    )
    |> Repo.exists?()
  end

  def permission?(permission_list, permission) when is_bitstring(permission),
    do: permission?(permission_list, [permission])

  def permission?(permission_list, permissions) when is_list(permissions) do
    Enum.find(permission_list, &(&1.permission in permissions)) != nil
  end
end
