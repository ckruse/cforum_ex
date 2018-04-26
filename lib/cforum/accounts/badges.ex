defmodule Cforum.Accounts.Badges do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Accounts.Badge

  @doc """
  Returns the list of badges.

  ## Examples

      iex> list_badges()
      [%Badge{}, ...]

  """
  def list_badges do
    from(badge in Badge, order_by: [asc: :order])
    |> Repo.all()
  end

  @doc """
  Gets a single badge.

  Raises `Ecto.NoResultsError` if the Badge does not exist.

  ## Examples

      iex> get_badge!(123)
      %Badge{}

      iex> get_badge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge!(id), do: Repo.get!(Badge, id)

  @doc """
  Creates a badge.

  ## Examples

      iex> create_badge(%{field: value})
      {:ok, %Badge{}}

      iex> create_badge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge(attrs \\ %{}) do
    %Badge{}
    |> Badge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a badge.

  ## Examples

      iex> update_badge(badge, %{field: new_value})
      {:ok, %Badge{}}

      iex> update_badge(badge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge(%Badge{} = badge, attrs) do
    badge
    |> Badge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Badge.

  ## Examples

      iex> delete_badge(badge)
      {:ok, %Badge{}}

      iex> delete_badge(badge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_badge(%Badge{} = badge) do
    Repo.delete(badge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge changes.

  ## Examples

      iex> change_badge(badge)
      %Ecto.Changeset{source: %Badge{}}

  """
  def change_badge(%Badge{} = badge) do
    Badge.changeset(badge, %{})
  end
end
