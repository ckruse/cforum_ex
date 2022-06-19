defmodule Cforum.Jobs.ArchiverJobTest do
  use Cforum.DataCase

  alias Cforum.Threads
  alias Cforum.Jobs.ArchiverJob

  setup do
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum)

    {:ok, message: message, thread: thread, forum: forum}
  end

  test "archive/0 archives a thread because it has to many messages", %{thread: thread, forum: forum} do
    insert(:setting, options: %{"max_messages_per_thread" => 1})
    insert(:message, thread: thread, forum: forum)

    ArchiverJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0} == Oban.drain_queue(queue: :background)

    thread = Threads.get_thread!(thread.thread_id)
    assert thread.archived == true
  end

  test "archive/0 archives a thread because there are to many threads", %{forum: forum, thread: old_thread} do
    insert(:setting, options: %{"max_threads" => 1})
    thread = insert(:thread, forum: forum)
    insert(:message, thread: thread, forum: forum)

    ArchiverJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0} == Oban.drain_queue(queue: :background)

    thread = Threads.get_thread!(old_thread.thread_id)
    assert thread.archived == true
  end

  test "archive/0 deletes a thread set to no-archive", %{thread: thread, forum: forum} do
    insert(:setting, options: %{"max_messages_per_thread" => 1})
    insert(:message, thread: thread, forum: forum)

    Threads.flag_thread_no_archive(nil, thread)

    ArchiverJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0} == Oban.drain_queue(queue: :background)

    assert_raise Ecto.NoResultsError, fn -> Threads.get_thread!(thread.thread_id) end
  end

  test "archive/0 archives deleted threads older than max age", %{forum: forum} do
    insert(:setting, options: %{"max_age_deleted" => 30})

    old_thread = insert(:thread, forum: forum, latest_message: Timex.shift(Timex.now(), seconds: -60), deleted: true)

    ArchiverJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0} == Oban.drain_queue(queue: :background)

    thread = Threads.get_thread!(old_thread.thread_id)
    assert thread.archived == true
  end

  test "archive/0 ignores deleted threads younger than max age", %{forum: forum} do
    insert(:setting, options: %{"max_age_deleted" => 120})

    old_thread = insert(:thread, forum: forum, created_at: Timex.shift(Timex.now(), seconds: -60), deleted: true)

    ArchiverJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0} == Oban.drain_queue(queue: :background)

    thread = Threads.get_thread!(old_thread.thread_id)
    assert thread.archived == false
  end

  test "archive/0 ignores deleted threads when max age is 0", %{forum: forum} do
    insert(:setting, options: %{"max_age_deleted" => 0})

    old_thread = insert(:thread, forum: forum, created_at: Timex.shift(Timex.now(), days: -60), deleted: true)

    ArchiverJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0} == Oban.drain_queue(queue: :background)

    thread = Threads.get_thread!(old_thread.thread_id)
    assert thread.archived == false
  end
end
