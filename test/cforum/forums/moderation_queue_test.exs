defmodule Cforum.Forums.ModerationQueueTest do
  use Cforum.DataCase

  alias Cforum.Forums.ModerationQueue
  alias Cforum.Forums.ModerationQueueEntry
  alias Cforum.Forums.Threads

  setup do
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum)
    message1 = insert(:message, thread: thread, forum: forum, parent_id: message.message_id)

    {:ok, forum: forum, thread: thread, message: message, message1: message1}
  end

  test "list_entries/1 returns all entries", %{message: message, message1: message1} do
    entry = insert(:moderation_queue_entry, message: message)
    entry1 = insert(:moderation_queue_entry, message: message1, cleared: true)
    entries = ModerationQueue.list_entries([message.forum])

    ids =
      entries
      |> Enum.map(& &1.moderation_queue_entry_id)
      |> Enum.sort(&(&1 >= &2))

    assert ids == [entry1.moderation_queue_entry_id, entry.moderation_queue_entry_id]
  end

  test "list_entries/1 w/ only_open: true returns only open entries", %{message: message, message1: message1} do
    entry = insert(:moderation_queue_entry, message: message)
    insert(:moderation_queue_entry, message: message1, cleared: true)
    entries = ModerationQueue.list_entries([message.forum], only_open: true)
    assert Enum.map(entries, & &1.moderation_queue_entry_id) == [entry.moderation_queue_entry_id]
  end

  test "count_entries/1 counts all entries", %{message: message, message1: message1} do
    insert(:moderation_queue_entry, message: message)
    insert(:moderation_queue_entry, message: message1, cleared: true)
    assert ModerationQueue.count_entries([message.forum]) == 2
  end

  test "count_entries/1 w/ only_open true counts only open entries", %{message: message, message1: message1} do
    insert(:moderation_queue_entry, message: message)
    insert(:moderation_queue_entry, message: message1, cleared: true)
    assert ModerationQueue.count_entries([message.forum], true) == 1
  end

  test "get_entry!/1 returns the entry with given id", %{message: message} do
    entry = insert(:moderation_queue_entry, message: message)

    assert ModerationQueue.get_entry!(entry.moderation_queue_entry_id).moderation_queue_entry_id ==
             entry.moderation_queue_entry_id
  end

  test "get_entry_by_message_id/1 returns the entry for the given message id", %{message: message} do
    entry = insert(:moderation_queue_entry, message: message)
    found_entry = ModerationQueue.get_entry_by_message_id(message.message_id)

    assert %ModerationQueueEntry{} = found_entry
    assert found_entry.moderation_queue_entry_id == entry.moderation_queue_entry_id
  end

  test "get_entry_by_message_id/1 returns nil when no entry was found", %{message: message} do
    assert ModerationQueue.get_entry_by_message_id(message.message_id) == nil
  end

  test "create_entry/1 with valid data creates a moderation queue entry", %{message: message} do
    attrs = params_for(:moderation_queue_entry, message: message)
    assert {:ok, %ModerationQueueEntry{} = entry} = ModerationQueue.create_entry(attrs)
    assert entry.cleared == attrs[:cleared]
    assert entry.reported == attrs[:reported]
    assert entry.message_id == attrs[:message_id]
    assert entry.reason == attrs[:reason]
  end

  test "create_entry/1 with reason=duplicate requires an url", %{message: message} do
    attrs = params_for(:moderation_queue_entry, message: message, reason: "duplicate")
    assert {:error, %Ecto.Changeset{}} = ModerationQueue.create_entry(attrs)

    attrs =
      params_for(
        :moderation_queue_entry,
        message: message,
        reason: "duplicate",
        duplicate_url: "http://example.org/foo"
      )

    assert {:ok, %ModerationQueueEntry{}} = ModerationQueue.create_entry(attrs)
  end

  test "create_entry/1 with reason=custom requires a custom reason", %{message: message} do
    attrs = params_for(:moderation_queue_entry, message: message, reason: "custom")
    assert {:error, %Ecto.Changeset{}} = ModerationQueue.create_entry(attrs)

    attrs =
      params_for(
        :moderation_queue_entry,
        message: message,
        reason: "custom",
        custom_reason: "The rebellion will win!"
      )

    assert {:ok, %ModerationQueueEntry{}} = ModerationQueue.create_entry(attrs)
  end

  test "create_entry/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = ModerationQueue.create_entry(%{})
  end

  test "increase_reported_count/1 increases the reported count of an entry", %{message: m} do
    entry = insert(:moderation_queue_entry, message: m)
    assert {:ok, updated_entry} = ModerationQueue.increase_reported_count(entry)
    assert updated_entry.reported == 2
  end

  test "create_or_update_entry/1 increases the reported count for existing entry", %{message: message} do
    entry = insert(:moderation_queue_entry, message: message)
    attrs = params_for(:moderation_queue_entry, message: message)
    assert {:ok, %ModerationQueueEntry{} = new_entry} = ModerationQueue.create_or_update_entry(message, attrs)
    assert new_entry.moderation_queue_entry_id == entry.moderation_queue_entry_id
    assert new_entry.reported == 2
  end

  test "create_or_update_entry/1 creates a new entry", %{message: message} do
    attrs = params_for(:moderation_queue_entry, message: message)
    assert {:ok, %ModerationQueueEntry{} = new_entry} = ModerationQueue.create_or_update_entry(message, attrs)
    assert new_entry.reported == 1
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

  describe "resolving" do
    setup %{message: m} do
      entry = insert(:moderation_queue_entry, message: m)
      user = insert(:user)

      {:ok, entry: entry, user: user}
    end

    test "change_resolve_entry/1 returns a moderation queue entry changeset", %{user: user, entry: entry} do
      assert %Ecto.Changeset{} = ModerationQueue.change_resolve_entry(user, entry)
    end

    test "resolve_entry/3 resolves an entry", %{entry: entry, user: u} do
      assert {:ok, %ModerationQueueEntry{cleared: true}} =
               ModerationQueue.resolve_entry(u, entry, %{"resolution" => "foobar", "resolution_action" => "none"})
    end

    test "resolve_entry/3 resolves an entry and sets message and children to no-answer", %{
      entry: entry,
      user: u,
      message: m
    } do
      assert {:ok, %ModerationQueueEntry{cleared: true}} =
               ModerationQueue.resolve_entry(u, entry, %{"resolution" => "foobar", "resolution_action" => "close"})

      thread = Threads.get_thread!(m.thread_id)
      assert length(Enum.filter(thread.messages, &(&1.flags["no-answer"] == "yes"))) == 2
    end

    test "resolve_entry/3 resolves an entry and deletes message and children", %{entry: entry, user: u, message: m} do
      assert {:ok, %ModerationQueueEntry{cleared: true}} =
               ModerationQueue.resolve_entry(u, entry, %{"resolution" => "foobar", "resolution_action" => "delete"})

      assert_raise Ecto.NoResultsError, fn ->
        Threads.get_thread!(m.thread_id)
        |> Threads.reject_deleted_threads()
        |> Threads.ensure_found!()
      end
    end

    test "resolve_entry/3 resolves an entry and sets thread to no-archive", %{entry: entry, user: u, message: m} do
      assert {:ok, %ModerationQueueEntry{cleared: true}} =
               ModerationQueue.resolve_entry(u, entry, %{"resolution" => "foobar", "resolution_action" => "no-archive"})

      thread = Threads.get_thread!(m.thread_id)
      assert thread.flags["no-archive"] == "yes"
    end
  end
end
