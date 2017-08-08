defmodule Cforum.Accounts.PrivMessages do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Accounts.PrivMessage

  @doc """
  Returns the list of priv_messages.

  ## Examples

      iex> list_priv_messages()
      [%PrivMessage{}, ...]

  """
  def list_priv_messages do
    Repo.all(PrivMessage)
  end

  def count_priv_messages(user, only_unread \\ false)
  def count_priv_messages(user, false) do
    from(pm in PrivMessage,
      where: pm.owner_id == ^user.user_id,
      select: count("*")
    )
    |> Repo.one
  end
  def count_priv_messages(user, true) do
    from(pm in PrivMessage,
      where: pm.owner_id == ^user.user_id and pm.is_read == false,
      select: count("*")
    )
    |> Repo.one
  end

  @doc """
  Gets a single priv_messages.

  Raises `Ecto.NoResultsError` if the Priv messages does not exist.

  ## Examples

      iex> get_priv_messages!(123)
      %PrivMessage{}

      iex> get_priv_messages!(456)
      ** (Ecto.NoResultsError)

  """
  def get_priv_message!(id), do: Repo.get!(PrivMessage, id)

  @doc """
  Creates a priv_messages.

  ## Examples

      iex> create_priv_messages(%{field: value})
      {:ok, %PrivMessage{}}

      iex> create_priv_messages(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_priv_message(attrs \\ %{}) do
    %PrivMessage{}
    |> PrivMessage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a priv_messages.

  ## Examples

      iex> update_priv_messages(priv_messages, %{field: new_value})
      {:ok, %PrivMessage{}}

      iex> update_priv_messages(priv_messages, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_priv_message(%PrivMessage{} = priv_messages, attrs) do
    priv_messages
    |> PrivMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PrivMessage.

  ## Examples

      iex> delete_priv_messages(priv_messages)
      {:ok, %PrivMessage{}}

      iex> delete_priv_messages(priv_messages)
      {:error, %Ecto.Changeset{}}

  """
  def delete_priv_message(%PrivMessage{} = priv_messages) do
    Repo.delete(priv_messages)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking priv_messages changes.

  ## Examples

      iex> change_priv_messages(priv_messages)
      %Ecto.Changeset{source: %PrivMessage{}}

  """
  def change_priv_message(%PrivMessage{} = priv_messages) do
    PrivMessage.changeset(priv_messages, %{})
  end
end
