defmodule CforumWeb.Api.V1.Threads.OpenCloseControllerTest do
  use CforumWeb.ConnCase
  alias Cforum.OpenClose

  setup %{conn: conn} do
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    user = insert(:user)

    {:ok, forum: forum, thread: thread, message: message, conn: login(conn, user), user: user}
  end

  describe "open" do
    test "opens a thread", %{conn: conn, thread: thread, forum: forum, user: user} do
      OpenClose.close_thread(user, thread)
      conn = post(conn, "/api/v1/threads/open", forum: forum.slug, slug: thread.slug)
      assert html_response(conn, 200) =~ gettext("Thread is currently open. Close it.")
    end

    test "doesn't fail for an openthread", %{conn: conn, thread: thread, forum: forum} do
      conn = post(conn, "/api/v1/threads/open", forum: forum.slug, slug: thread.slug)
      assert html_response(conn, 200) =~ gettext("Thread is currently open. Close it.")
    end
  end

  describe "close" do
    test "closes a thread", %{conn: conn, thread: thread, forum: forum} do
      conn = post(conn, "/api/v1/threads/close", forum: forum.slug, slug: thread.slug)
      assert html_response(conn, 200) =~ gettext("Thread is currently closed. Open it.")
    end

    test "doesn't fail on a closed", %{conn: conn, thread: thread, forum: forum, user: user} do
      OpenClose.close_thread(user, thread)
      conn = post(conn, "/api/v1/threads/close", forum: forum.slug, slug: thread.slug)
      assert html_response(conn, 200) =~ gettext("Thread is currently closed. Open it.")
    end
  end
end
