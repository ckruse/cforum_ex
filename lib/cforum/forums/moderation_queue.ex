defmodule Cforum.Forums.ModerationQueue do
  @moduledoc """
  The boundary for the moderation queue system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Forums.ModerationQueueEntry
  alias Cforum.System
  alias Cforum.Forums.{Threads, Messages}

  @doc """
  Returns the list of entries.

  ## Examples

      iex> list_entries()
      [%ModerationQueueEntry{}, ...]

  """
  def list_entries(forums, query_params \\ [order: nil, limit: nil, only_open: false]) do
    fids = Enum.map(forums, & &1.forum_id)

    from(
      entry in ModerationQueueEntry,
      inner_join: m in assoc(entry, :message),
      where: m.forum_id in ^fids,
      preload: [:closer, message: [:user, thread: :forum]],
      order_by: [desc: :created_at]
    )
    |> maybe_only_open(query_params[:only_open])
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Repo.all()
  end

  def count_entries(forums, only_open \\ false) do
    fids = Enum.map(forums, & &1.forum_id)

    from(
      entry in ModerationQueueEntry,
      inner_join: m in assoc(entry, :message),
      select: count("*"),
      where: m.forum_id in ^fids
    )
    |> maybe_only_open(only_open)
    |> Repo.one()
  end

  defp maybe_only_open(q, true), do: from(e in q, where: e.cleared == false)
  defp maybe_only_open(q, _), do: q

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
    |> Repo.preload([:closer, message: [thread: :forum]])
  end

  def get_entry_by_message_id(mid) do
    ModerationQueueEntry
    |> Repo.get_by(message_id: mid)
    |> Repo.preload([:closer, message: [thread: :forum]])
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
        increase_reported_count(entry)
    end
  end

  def increase_reported_count(entry) do
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

  def change_resolve_entry(current_user, %ModerationQueueEntry{} = entry) do
    ModerationQueueEntry.resolve_changeset(current_user, entry, %{})
  end

  def resolve_entry(user, %ModerationQueueEntry{message: message} = entry, attrs) do
    System.audited("update", user, fn ->
      {:ok, entry} =
        user
        |> ModerationQueueEntry.resolve_changeset(entry, attrs)
        |> Repo.update()

      apply_resolution_action(entry.resolution_action, user, message)

      {:ok, entry}
    end)
  end

  defp apply_resolution_action("close", user, message) do
    {_, message} =
      Messages.get_message_and_thread!(nil, nil, user, message.thread_id, message.message_id, view_all: true)

    {:ok, _msg} = Messages.flag_no_answer(user, message)
  end

  defp apply_resolution_action("delete", user, message) do
    {_, message} =
      Messages.get_message_and_thread!(nil, nil, user, message.thread_id, message.message_id, view_all: true)

    {:ok, _msg} = Messages.delete_message(user, message)
  end

  defp apply_resolution_action("no-archive", user, message) do
    thread = Threads.get_thread!(nil, nil, user, message.thread_id, view_all: true)
    {:ok, _thread} = Threads.flag_thread_no_archive(user, thread)
  end

  defp apply_resolution_action(_, _, _), do: nil
end
