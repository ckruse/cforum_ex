defmodule Cforum.Forums.ModerationQueueTest do
  use Cforum.DataCase

  alias Cforum.Forums.ModerationQueue
  alias Cforum.Forums.ModerationQueueEntry

  test "list_entries/1 returns all archived entries", %{message: message} do
    entry = insert(:moderation_queue_entry, message: message)
    entries = ModerationQueue.list_entries()
    assert Enum.map(entries, & &1.moderation_queue_entry_id) == [entry.moderation_queue_entry_id]
  end

  test "count_entries/1 counts all entries", %{message: message} do
    insert(:moderation_queue_entry, message: message)
    assert ModerationQueue.count_entries() == 1
  end

  test "get_entry!/1 returns the entry with given id", %{message: message} do
    entry = insert(:moderation_queue_entry, message: message)

    assert ModerationQueue.get_entry!(entry.moderation_queue_entry_id).moderation_queue_entry_id ==
             entry.moderation_queue_entry_id
  end

  test "create_entry/1 with valid data creates a moderation queue entry", %{message: message} do
    attrs = params_for(:moderation_queue_entry, message: message)
    assert {:ok, %ModerationQueueEntry{} = entry} = ModerationQueue.create_entry(attrs)
    assert entry.cleared == attrs[:cleared]
    assert entry.reported == attrs[:reported]
    assert entry.message_id == attrs[:message_id]
    assert entry.reason == attrs[:reason]
  end

  test "create_cite/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = ModerationQueue.create_entry(%{})
  end

  test "update_entry/2 with valid data updates the entry", %{message: message} do
    entry = insert(:moderation_queue_entry, message: message)
    assert {:ok, entry} = ModerationQueue.update_entry(entry, %{reported: 2})
    assert %ModerationQueueEntry{} = entry
    assert entry.reported == 2
  end

  test "update_entry/2 with invalid data returns error changeset", %{message: message} do
    entry = insert(:moderation_queue_entry, message: message)
    assert {:error, %Ecto.Changeset{}} = ModerationQueue.update_entry(entry, %{reason: nil})

    entry1 = ModerationQueue.get_entry!(entry.moderation_queue_entry_id)

    assert entry.cleared == entry1.cleared
    assert entry.reported == entry1.reported
    assert entry.message_id == entry1.message_id
    assert entry.reason == entry1.reason
  end

  test "delete_entry/1 deletes the entry", %{message: message} do
    entry = insert(:moderation_queue_entry, message: message)
    assert {:ok, %ModerationQueueEntry{}} = ModerationQueue.delete_entry(entry)
    assert_raise Ecto.NoResultsError, fn -> ModerationQueue.get_entry!(entry.moderation_queue_entry_id) end
  end

  test "change_create_entry/1 returns a moderation queue entry changeset", %{message: message} do
    entry = insert(:moderation_queue_entry, message: message)
    assert %Ecto.Changeset{} = ModerationQueue.change_create_entry(entry)
  end

  setup do
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum)

    {:ok, forum: forum, thread: thread, message: message}
  end
end
