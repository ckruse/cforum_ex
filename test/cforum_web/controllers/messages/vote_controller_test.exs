defmodule CforumWeb.Messages.VoteControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_tests]

  alias Cforum.Messages

  describe "upvote" do
    test "votes up", %{conn: conn, thread: thread, message: message, forum: forum} do
      conn = post(conn, Path.message_path(conn, :upvote, thread, message, f: forum.slug, r: "message"))
      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Successfully upvoted message")
    end

    test "takes back a vote", %{conn: conn, thread: thread, message: message, forum: forum} do
      conn = post(conn, Path.message_path(conn, :upvote, thread, message))
      conn = post(conn, Path.message_path(conn, :upvote, thread, message, f: forum.slug, r: "message"))
      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Successfully took back vote")
    end
  end

  describe "downvote" do
    test "votes down", %{conn: conn, thread: thread, message: message, forum: forum} do
      conn = post(conn, Path.message_path(conn, :downvote, thread, message, f: forum.slug, r: "message"))
      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Successfully downvoted message")
    end

    test "takes back a vote", %{conn: conn, thread: thread, message: message, forum: forum} do
      conn = post(conn, Path.message_path(conn, :downvote, thread, message))
      conn = post(conn, Path.message_path(conn, :downvote, thread, message, f: forum.slug, r: "message"))
      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Successfully took back vote")
    end
  end

  describe "inverting" do
    test "takes back a an upvote and creates a downvote", %{conn: conn, thread: thread, message: message, forum: forum} do
      conn = post(conn, Path.message_path(conn, :upvote, thread, message))
      conn = post(conn, Path.message_path(conn, :downvote, thread, message, f: forum.slug, r: "message"))
      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Successfully downvoted message")

      message = Messages.get_message!(message.message_id)
      assert message.upvotes == 0
      assert message.downvotes == 1
    end

    test "takes back a downvote and creates an upvote", %{conn: conn, thread: thread, message: message, forum: forum} do
      conn = post(conn, Path.message_path(conn, :downvote, thread, message))
      conn = post(conn, Path.message_path(conn, :upvote, thread, message, f: forum.slug, r: "message"))
      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Successfully upvoted message")

      message = Messages.get_message!(message.message_id)
      assert message.upvotes == 1
      assert message.downvotes == 0
    end
  end

  defp setup_tests(%{conn: conn}) do
    user = build(:user) |> as_admin() |> insert
    Cforum.Accounts.Scores.create_score(%{user_id: user.user_id, value: 1000})

    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    {:ok, user: user, conn: login(conn, user), thread: thread, message: message, forum: forum}
  end
end
