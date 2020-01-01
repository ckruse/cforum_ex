defmodule CforumWeb.Api.V1.Threads.InvisibleControllerTest do
  use CforumWeb.ConnCase
  alias Cforum.InvisibleThreads

  setup %{conn: conn} do
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    user = insert(:user)

    {:ok, forum: forum, thread: thread, message: message, conn: login(conn, user), user: user}
  end

  describe "hide" do
    test "hides a thread", %{conn: conn, thread: thread, forum: forum} do
      conn = post(conn, "/api/v1/threads/hide", forum: forum.slug, slug: thread.slug)
      assert json_response(conn, 200) == %{"status" => "ok"}
    end

    test "fails when a thread is hidden", %{conn: conn, thread: thread, forum: forum, user: user} do
      InvisibleThreads.hide_thread(user, thread)
      assert_error_sent(403, fn -> post(conn, "/api/v1/threads/hide", forum: forum.slug, slug: thread.slug) end)
    end
  end

  describe "unhide" do
    test "unhides a thread", %{conn: conn, thread: thread, forum: forum, user: user} do
      InvisibleThreads.hide_thread(user, thread)
      conn = post(conn, "/api/v1/threads/unhide", forum: forum.slug, slug: thread.slug)
      assert json_response(conn, 200) == %{"status" => "ok"}
    end

    test "fails when a thread isn't hidden", %{conn: conn, thread: thread, forum: forum} do
      assert_error_sent(403, fn -> post(conn, "/api/v1/threads/unhide", forum: forum.slug, slug: thread.slug) end)
    end
  end
end
