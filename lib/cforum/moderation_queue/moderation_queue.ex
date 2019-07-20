defmodule Cforum.ModerationQueue do
  @moduledoc """
  The boundary for the moderation queue system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.ModerationQueue.ModerationQueueEntry
  alias Cforum.System
  alias Cforum.Threads
  alias Cforum.Messages
  alias Cforum.Forums

  alias Cforum.Accounts.Users
  alias Cforum.ConfigManager

  alias CforumWeb.NotificationMailer

  @doc """
  Returns the list of entries.

  ## Parameters
  - `forums` defines the forums the user has access to
  - `query_params` defines the parameters to the query with the
    following keys:
    - `only_open` if true, only list open entries. List all
      entries otherwise
    - `order` specifies the order of the list, see Cforum.OrderApi for
      details
    - `limit` specifies the paging, see Cforum.PagingApi for details

  ## Examples

      iex> list_entries([%Forum{}])
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

  @doc """
  Counts the entries in the moderation queue.

  ## Parameters

  - `forums` defines the forums the user has access to
  - `only_open` if true, only count open entries. Count all entries
    otherwise

  ## Examples

      iex> count_entries([%Forum{}])
      1

  """
  def count_entries(forums, only_open \\ false) do
    fids = Enum.map(forums, & &1.forum_id)

    from(
      entry in ModerationQueueEntry,
      inner_join: m in assoc(entry, :message),
      select: count("*"),
      where: m.forum_id in ^fids
    )
    |> maybe_only_open(only_open)
    |> Repo.one!()
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

  @doc """
  Gets a single entry by the message ID.

  Returns `nil` if entry doesn't exist

  ## Examples

      iex> get_entry_by_message_id(123)
      %ModerationQueueEntry{}

      iex> get_entry_by_message_id(456)
      nil

  """
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
    |> maybe_notify_moderators()
  end

  @doc """
  Creates a new entry or increases the reported count of an existing
  entry, depending on if an entry for this message exists or not.

  ## Parameters

  - `message` the message to create the entry for
  - `attrs` the attributes for the moderation queue entry

  ## Examples

      iex> create_or_update_entry(%Message{}, %{field: value})
      {:ok, %ModerationQueueEntry{}}

      iex> create_or_update_entry(%Message{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_update_entry(message, attrs) do
    case get_entry_by_message_id(message.message_id) do
      nil ->
        create_entry(attrs)

      entry ->
        increase_reported_count(entry)
    end
  end

  @doc """
  Increases the `reported` count for an entry

  ## Examples

      iex> increase_reported_count(%ModerationQueueEntry{})
      {:ok, %ModerationQueueEntry{}}

  """
  def increase_reported_count(entry) do
    {1, [ent]} =
      from(e in ModerationQueueEntry,
        where: e.moderation_queue_entry_id == ^entry.moderation_queue_entry_id,
        select: e
      )
      |> Repo.update_all(inc: [reported: 1])

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
  Returns an `%Ecto.Changeset{}` for tracking entry changes on creation.

  ## Examples

      iex> change_create_entry(entry)
      %Ecto.Changeset{source: %ModerationQueueEntry{}}

  """
  def change_create_entry(%ModerationQueueEntry{} = entry) do
    ModerationQueueEntry.create_changeset(entry, %{})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entry changes on
  resolving an entry.

  ## Examples

      iex> change_resolve_entry(%User{}, entry)
      %Ecto.Changeset{source: %ModerationQueueEntry{}}

  """
  def change_resolve_entry(current_user, %ModerationQueueEntry{} = entry) do
    ModerationQueueEntry.resolve_changeset(current_user, entry, %{})
  end

  @doc """
  Marks an entry as resolved and applies the resolution action

  ## Parameters

  - `user` is the resolving (current) user
  - `entry` is the entry to resolve
  - `attrs` are the resolution attributes

  ## Examples

      iex> resolve_entry(%User{}, entry, %{"field" => "value"})
      {:ok, %ModerationQueueEntry{}}

  """
  def resolve_entry(user, %ModerationQueueEntry{message: message} = entry, attrs) do
    System.audited("update", user, fn ->
      ret =
        user
        |> ModerationQueueEntry.resolve_changeset(entry, attrs)
        |> Repo.update()

      case ret do
        {:ok, entry} ->
          apply_resolution_action(entry.resolution_action, user, message)
          {:ok, entry}

        _ ->
          ret
      end
    end)
  end

  defp apply_resolution_action("close", user, message) do
    thread =
      Threads.get_thread!(message.thread_id)
      |> Threads.build_message_tree("ascending")

    message = Messages.get_message_from_mid!(thread, message.message_id)

    {:ok, _msg} = Messages.flag_no_answer(user, message, "no-answer")
  end

  defp apply_resolution_action("delete", user, message) do
    thread =
      Threads.get_thread!(message.thread_id)
      |> Threads.build_message_tree("ascending")

    message = Messages.get_message_from_mid!(thread, message.message_id)
    {:ok, _msg} = Messages.delete_message(user, message)
  end

  defp apply_resolution_action("no-archive", user, message) do
    thread = Threads.get_thread!(message.thread_id)
    {:ok, _thread} = Threads.flag_thread_no_archive(user, thread)
  end

  defp apply_resolution_action(_, _, _), do: nil

  defp maybe_notify_moderators({:ok, entry}) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      m = Messages.get_message!(entry.message_id, view_all: true)
      forum = Forums.get_forum!(m.forum_id)
      {thread, message} = Messages.get_message_and_thread!(forum, nil, m.thread_id, m.message_id, view_all: true)

      forum
      |> Users.list_moderators()
      |> Enum.filter(&(ConfigManager.uconf(&1, "notify_on_flagged") == "email"))
      |> Enum.each(&send_moderation_mail(&1, entry, thread, message))
    end)

    {:ok, entry}
  end

  defp maybe_notify_moderators(val), do: val

  defp send_moderation_mail(user, entry, thread, message) do
    user
    |> NotificationMailer.moderation_mail(entry, thread, message)
    |> Cforum.Mailer.deliver_later()
  end
end
