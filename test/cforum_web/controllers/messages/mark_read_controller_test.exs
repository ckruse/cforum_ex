defmodule CforumWeb.Messages.MarkReadControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_tests]

  alias Cforum.Forums.Messages

  describe "marking a thread read" do
    test "marks a thread read", %{conn: conn, forum: forum, thread: thread, message: message} do
      conn = post(conn, mark_read_path(conn, :mark_read, thread), f: forum.slug, r: "message")
      assert redirected_to(conn) == message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Thread has successfully been marked as read.")
    end

    test "doesn't fail when a thread is already marked read", %{
      conn: conn,
      user: user,
      forum: forum,
      thread: thread,
      message: message
    } do
      Messages.mark_messages_read(user, message)
      conn = post(conn, mark_read_path(conn, :mark_read, thread), f: forum.slug, r: "message")
      assert redirected_to(conn) == message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Thread has successfully been marked as read.")
    end
  end

  defp setup_tests(%{conn: conn}) do
    user = build(:user) |> insert

    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    {:ok, user: user, conn: login(conn, user), thread: thread, message: message, forum: forum}
  end
end
