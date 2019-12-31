defmodule CforumWeb.Threads.InvisibleControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.InvisibleThreads
  alias Cforum.Messages

  setup %{conn: conn} do
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    user = insert(:user)

    {:ok, forum: forum, thread: thread, message: message, conn: login(conn, user), user: user}
  end

  describe "index" do
    test "lists invisible threads", %{conn: conn, thread: thread, user: user, message: message} do
      InvisibleThreads.hide_thread(user, thread)
      conn = get(conn, Routes.invisible_path(conn, :index))
      assert html_response(conn, 200) =~ message.subject
    end

    test "doesn't fail when there is no invisible thread", %{conn: conn} do
      conn = get(conn, Routes.invisible_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("invisible threads")
    end

    test "doesn't fail with a thread with only one deleted message", %{
      conn: conn,
      thread: thread,
      user: user,
      message: message
    } do
      InvisibleThreads.hide_thread(user, thread)
      Messages.delete_message(user, %{message | messages: []}, "spam")
      conn = get(conn, Routes.invisible_path(conn, :index))
      assert html_response(conn, 200) =~ message.subject
    end
  end

  describe "hide" do
    test "hides a thread", %{conn: conn, thread: thread, forum: forum} do
      conn = post(conn, Path.thread_path(conn, :hide, thread))
      assert redirected_to(conn) == Path.forum_path(conn, :index, forum)
    end

    test "doesn't fail on an already hidden thread", %{conn: conn, thread: thread, user: user} do
      InvisibleThreads.hide_thread(user, thread)
      assert_error_sent(403, fn -> post(conn, Path.thread_path(conn, :hide, thread)) end)
    end
  end

  describe "unhide" do
    test "unhides a thread", %{conn: conn, thread: thread, forum: forum, user: user} do
      InvisibleThreads.hide_thread(user, thread)
      conn = post(conn, Path.thread_path(conn, :unhide, thread))
      assert redirected_to(conn) == Path.forum_path(conn, :index, forum)
    end

    test "doesn't fail on an already unhidden thread", %{conn: conn, thread: thread} do
      assert_error_sent(403, fn -> post(conn, Path.thread_path(conn, :unhide, thread)) end)
    end
  end
end
