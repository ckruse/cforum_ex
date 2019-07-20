defmodule Cforum.Accounts.Groups do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Accounts.Group
  alias Cforum.System
  alias Cforum.Caching

  def discard_group_cache({:ok, group}) do
    Caching.del(:cforum, "groups")
    {:ok, group}
  end

  def discard_group_cache(val), do: val

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Caching.fetch(:cforum, "groups", fn ->
      from(group in Group, preload: [:users, :permissions], order_by: [desc: :name])
      |> Repo.all()
    end)
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
    with {:ok, id} <- Ecto.Type.cast(:integer, id),
         %Group{} = group <- Enum.find(list_groups(), &(&1.group_id == id)) do
      group
    else
      _ -> raise Ecto.NoResultsError, queryable: Group
    end
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(current_user, attrs \\ %{}) do
    System.audited("create", current_user, fn ->
      %Group{}
      |> Group.changeset(attrs)
      |> Repo.insert()
    end)
    |> discard_group_cache()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(current_user, %Group{} = group, attrs) do
    System.audited("update", current_user, fn ->
      group
      |> Group.changeset(attrs)
      |> Repo.update()
    end)
    |> discard_group_cache()
  end

  @doc """
  Deletes a Group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(current_user, %Group{} = group) do
    System.audited("destroy", current_user, fn ->
      Repo.delete(group)
    end)
    |> discard_group_cache()
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

  defp has_user?(users, user), do: Enum.any?(users, &(&1.user_id == user.user_id))

  def list_permissions_for_user_and_forum(user, forum) do
    list_groups()
    |> Enum.filter(&has_user?(&1.users, user))
    |> Enum.map(& &1.permissions)
    |> List.flatten()
    |> Enum.filter(&(&1.forum_id == forum.forum_id))
  end

  def list_permissions_for_user(user) do
    list_groups()
    |> Enum.filter(&has_user?(&1.users, user))
    |> Enum.map(& &1.permissions)
    |> List.flatten()
  end

  def permission?(user, forum, permission) when is_bitstring(permission), do: permission?(user, forum, [permission])

  def permission?(user, forum, permissions) when is_list(permissions) do
    list_groups()
    |> Enum.filter(&has_user?(&1.users, user))
    |> Enum.map(& &1.permissions)
    |> List.flatten()
    |> Enum.any?(&(&1.forum_id == forum.forum_id && &1.permission in permissions))
  end

  def permission?(permission_list, permission) when is_bitstring(permission),
    do: permission?(permission_list, [permission])

  def permission?(permission_list, permissions) when is_list(permissions),
    do: Enum.any?(permission_list, &(&1.permission in permissions))
end
