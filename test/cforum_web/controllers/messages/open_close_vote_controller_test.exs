defmodule CforumWeb.OpenCloseVoteControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Forums.{CloseVotes, CloseVoteVoter, Messages}

  setup [:setup_close_votes]

  describe "new close vote" do
    test "form for new close votes on open message", %{conn: conn, user: user, thread: thread, message: message} do
      conn =
        conn
        |> login(user)
        |> get(close_vote_path(conn, thread, message))

      assert html_response(conn, 200) =~
               gettext("Start a close vote for message %{subject} by %{author}",
                 subject: message.subject,
                 author: message.author
               )
    end

    test "responds with 403 for close on closed messages", %{conn: conn, user: user, message: message} do
      {thread, message} = Messages.get_message_and_thread!(nil, nil, nil, message.thread_id, message.message_id)
      Messages.flag_no_answer(nil, message, "no-answer")

      assert_error_sent(403, fn ->
        conn
        |> login(user)
        |> get(close_vote_path(conn, thread, message))
      end)
    end
  end

  describe "new reopen vote" do
    test "form for new close votes on closed message", %{conn: conn, user: user, message: message} do
      {thread, message} = Messages.get_message_and_thread!(nil, nil, nil, message.thread_id, message.message_id)
      Messages.flag_no_answer(nil, message, "no-answer")

      conn =
        conn
        |> login(user)
        |> get(open_vote_path(conn, thread, message))

      assert html_response(conn, 200) =~
               gettext("Start a reopen vote for message %{subject} by %{author}",
                 subject: message.subject,
                 author: message.author
               )
    end

    test "responds with 403 for reopen on open messages", %{conn: conn, user: user, thread: thread, message: message} do
      assert_error_sent(403, fn ->
        conn
        |> login(user)
        |> get(open_vote_path(conn, thread, message))
      end)
    end
  end

  describe "create close vote" do
    test "creates close vote and redirects when data is valid", %{
      conn: conn,
      user: user,
      thread: thread,
      message: message
    } do
      conn =
        conn
        |> login(user)
        |> post(close_vote_path(conn, thread, message), close_vote: params_for(:close_vote))

      assert redirected_to(conn) == message_path(conn, :show, thread, message)
    end

    test "does not create close vote and renders errors when data is invalid", %{
      conn: conn,
      user: user,
      message: message,
      thread: thread
    } do
      conn =
        conn
        |> login(user)
        |> post(close_vote_path(conn, thread, message), close_vote: %{})

      assert html_response(conn, 200) =~
               gettext("Start a close vote for message %{subject} by %{author}",
                 subject: message.subject,
                 author: message.author
               )
    end
  end

  describe "create reopen vote" do
    test "creates reopen vote and redirects when data is valid", %{conn: conn, user: user, message: message} do
      {thread, message} = Messages.get_message_and_thread!(nil, nil, nil, message.thread_id, message.message_id)
      Messages.flag_no_answer(nil, message, "no-answer")

      conn =
        conn
        |> login(user)
        |> post(open_vote_path(conn, thread, message), close_vote: %{reason: "custom", custom_reason: "foo"})

      assert redirected_to(conn) == message_path(conn, :show, thread, message)
    end

    test "does not create reopen vote and renders errors when data is invalid", %{conn: conn, user: user, message: m} do
      {thread, message} = Messages.get_message_and_thread!(nil, nil, nil, m.thread_id, m.message_id)
      Messages.flag_no_answer(nil, message, "no-answer")

      conn =
        conn
        |> login(user)
        |> post(open_vote_path(conn, thread, message), close_vote: %{})

      assert html_response(conn, 200) =~
               gettext("Start a reopen vote for message %{subject} by %{author}",
                 subject: message.subject,
                 author: message.author
               )
    end
  end

  describe "vote" do
    setup [:setup_votes]

    test "votes for a close vote", %{conn: conn, visiting_user: user, message: m, thread: t, close_vote: vote} do
      conn =
        conn
        |> login(user)
        |> patch(oc_vote_path(conn, t, m, vote))

      assert redirected_to(conn) == message_path(conn, :show, t, m)
      assert [%CloseVoteVoter{}] = CloseVotes.list_voters(vote)
    end

    test "votes for a reopen vote", %{conn: conn, visiting_user: user, message: m, reopen_vote: vote} do
      {thread, message} = Messages.get_message_and_thread!(nil, nil, nil, m.thread_id, m.message_id)
      Messages.flag_no_answer(nil, message, "no-answer")

      conn =
        conn
        |> login(user)
        |> patch(oc_vote_path(conn, thread, message, vote))

      assert redirected_to(conn) == message_path(conn, :show, thread, message)
      assert [%CloseVoteVoter{}] = CloseVotes.list_voters(vote)
    end

    test "does not vote for a closed vote", %{
      conn: conn,
      visiting_user: user,
      message: message,
      thread: thread,
      close_vote: vote
    } do
      changeset = Ecto.Changeset.change(vote, finished: true)
      assert {:ok, _} = Cforum.Repo.update(changeset)

      assert_error_sent(403, fn ->
        conn
        |> login(user)
        |> patch(oc_vote_path(conn, thread, message, vote))
      end)
    end

    test "voting again takes back the vote", %{conn: conn, visiting_user: user, message: m, thread: t, close_vote: vote} do
      conn =
        conn
        |> login(user)
        |> patch(oc_vote_path(conn, t, m, vote))

      assert redirected_to(conn) == message_path(conn, :show, t, m)
      assert [%CloseVoteVoter{}] = CloseVotes.list_voters(vote)

      conn = patch(conn, oc_vote_path(conn, t, m, vote))
      assert redirected_to(conn) == message_path(conn, :show, t, m)
      assert [] = CloseVotes.list_voters(vote)
    end
  end

  defp setup_votes(%{message: message}) do
    close_vote = insert(:close_vote, message: message)
    reopen_vote = insert(:close_vote, vote_type: true, message: message)
    {:ok, close_vote: close_vote, reopen_vote: reopen_vote}
  end

  defp setup_close_votes(_) do
    forum = insert(:public_forum)
    thread = insert(:thread)
    message = insert(:message, thread: thread, forum: forum)
    user = build(:user) |> insert
    visiting_user = build(:user) |> insert

    badge = insert(:badge, badge_type: Cforum.Accounts.Badge.visit_close_reopen())
    badge1 = insert(:badge, badge_type: Cforum.Accounts.Badge.create_close_reopen_vote())

    insert(:badge_user, user: user, badge: badge)
    insert(:badge_user, user: visiting_user, badge: badge)
    insert(:badge_user, user: user, badge: badge1)

    {:ok, forum: forum, user: user, thread: thread, message: message, visiting_user: visiting_user}
  end
end
