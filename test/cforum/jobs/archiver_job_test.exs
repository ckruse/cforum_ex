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
    assert %{success: 1, failure: 0} == Oban.drain_queue(:background)

    thread = Threads.get_thread!(thread.thread_id)
    assert thread.archived == true
  end

  test "archive/0 archives a thread because there are to many threads", %{forum: forum, thread: old_thread} do
    insert(:setting, options: %{"max_threads" => 1})
    thread = insert(:thread, forum: forum)
    insert(:message, thread: thread, forum: forum)

    ArchiverJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0} == Oban.drain_queue(:background)

    thread = Threads.get_thread!(old_thread.thread_id)
    assert thread.archived == true
  end

  test "archive/0 deletes a thread set to no-archive", %{thread: thread, forum: forum} do
    insert(:setting, options: %{"max_messages_per_thread" => 1})
    insert(:message, thread: thread, forum: forum)

    Threads.flag_thread_no_archive(nil, thread)

    ArchiverJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0} == Oban.drain_queue(:background)

    assert_raise Ecto.NoResultsError, fn -> Threads.get_thread!(thread.thread_id) end
  end
end
