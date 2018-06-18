defmodule Cforum.Forums.ModerationQueue do
  @moduledoc """
  The boundary for the moderation queue system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Forums.ModerationQueueEntry

  @doc """
  Returns the list of entries.

  ## Examples

      iex> list_entries()
      [%ModerationQueueEntry{}, ...]

  """
  def list_entries(query_params \\ [order: nil, limit: nil]) do
    from(
      entry in ModerationQueueEntry,
      preload: [:closer, message: [thread: :forum]]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
  end

  def count_entries() do
    from(
      entry in ModerationQueueEntry,
      select: count("*")
    )
    |> Repo.one()
  end

  @doc """
  Gets a single entry.

  Raises `Ecto.NoResultsError` if the entry does not exist.

  ## Examples

      iex> get_entry!(123)
      %ModerationQueueEntry{}

      iex> get_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_entry!(id) do
    ModerationQueueEntry
    |> Repo.get!(id)
    |> Repo.preload(:closer, message: [thread: :forum])
  end

  def get_entry_by_message_id(mid) do
    ModerationQueueEntry
    |> Repo.get_by(message_id: mid)
    |> Repo.preload(:closer, message: [thread: :forum])
  end

  @doc """
  Creates a entry.

  ## Examples

      iex> create_entry(%{field: value})
      {:ok, %ModerationQueueEntry{}}

      iex> create_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entry(attrs) do
    %ModerationQueueEntry{}
    |> ModerationQueueEntry.create_changeset(attrs)
    |> Repo.insert()
  end

  def create_or_update_entry(message, attrs) do
    case get_entry_by_message_id(message.message_id) do
      nil ->
        create_entry(attrs)

      entry ->
        increate_reported_count(entry)
    end
  end

  def increate_reported_count(entry) do
    {1, [ent]} =
      from(e in ModerationQueueEntry, where: e.moderation_queue_entry_id == ^entry.moderation_queue_entry_id)
      |> Repo.update_all([inc: [reported: 1]], returning: true)

    {:ok, ent}
  end

  @doc """
  Updates a entry.

  ## Examples

      iex> update_entry(entry, %{field: new_value})
      {:ok, %ModerationQueueEntry{}}

      iex> update_entry(entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_entry(%ModerationQueueEntry{} = entry, attrs) do
    entry
    |> ModerationQueueEntry.create_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a entry.

  ## Examples

      iex> delete_entry(entry)
      {:ok, %ModerationQueueEntry{}}

      iex> delete_entry(entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entry(%ModerationQueueEntry{} = entry) do
    Repo.delete(entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entry changes.

  ## Examples

      iex> change_create_entry(entry)
      %Ecto.Changeset{source: %ModerationQueueEntry{}}

  """
  def change_create_entry(%ModerationQueueEntry{} = entry) do
    ModerationQueueEntry.create_changeset(entry, %{})
  end
end
