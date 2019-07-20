defmodule CforumWeb.RedirectorControllerTest do
  use CforumWeb.ConnCase

  test "redirects to /all/archive on /archiv", %{conn: conn} do
    conn = get(conn, "/archiv")
    assert redirected_to(conn) == "/all/archive"
  end

  test "redirects to /all/archive/:year an /archiv/:year", %{conn: conn} do
    conn = get(conn, "/archiv/1999")
    assert redirected_to(conn) == "/all/1999"
  end

  test "redirects to /all/archive/:year an /archiv/:year_:no", %{conn: conn} do
    conn = get(conn, "/archiv/1999_2")
    assert redirected_to(conn) == "/all/1999"
  end

  test "fails on /archiv/:year with invalid year", %{conn: conn} do
    conn = get(conn, "/archiv/foobar")
    assert html_response(conn, 404)
  end

  test "redirects to thread on /archiv/:year/:tid", %{conn: conn} do
    thread = insert(:thread, tid: 1)
    message = insert(:message, forum: thread.forum, thread: thread)
    conn = get(conn, "/archiv/#{thread.created_at.year}/t1")
    assert redirected_to(conn) == CforumWeb.Views.Helpers.Path.message_path(conn, :show, thread, message)
  end

  test "redirects to thread on /archiv/:year_:no/:tid", %{conn: conn} do
    thread = insert(:thread, tid: 1)
    message = insert(:message, forum: thread.forum, thread: thread)
    conn = get(conn, "/archiv/#{thread.created_at.year}_2/t1")
    assert redirected_to(conn) == CforumWeb.Views.Helpers.Path.message_path(conn, :show, thread, message)
  end

  test "shows a list of threads on /archiv/:year/:tid with multiple threads found", %{conn: conn} do
    thread = insert(:thread, tid: 1)
    thread2 = insert(:thread, tid: 1)
    insert(:message, forum: thread.forum, thread: thread, subject: "thread 1")
    insert(:message, forum: thread2.forum, thread: thread2, subject: "thread 2")

    conn = get(conn, "/archiv/#{thread.created_at.year}_2/t1")
    assert html_response(conn, 200) =~ ~r/thread 1/
    assert html_response(conn, 200) =~ ~r/thread 2/
  end

  test "fails on /archiv/:year/:tid with not existing tid", %{conn: conn} do
    assert_error_sent(404, fn -> get(conn, "/archiv/1999/t1") end)
  end

  test "redirects to month on /archiv/:year/:mon", %{conn: conn} do
    conn = get(conn, "/archiv/1999/1")
    assert redirected_to(conn) == "/all/1999/jan"
  end

  test "redirects to month on /archiv/:year_:no/:mon", %{conn: conn} do
    conn = get(conn, "/archiv/1999_1/1")
    assert redirected_to(conn) == "/all/1999/jan"
  end

  test "fails on /archiv/:year/:mon with invalid year", %{conn: conn} do
    assert_error_sent(404, fn -> get(conn, "/archiv/foobar/1") end)
  end

  test "fails on /archiv/:year/:mon with invalid month", %{conn: conn} do
    assert_error_sent(404, fn -> get(conn, "/archiv/1999/foobar") end)
    assert_error_sent(404, fn -> get(conn, "/archiv/1999/13") end)
  end

  test "redirects to thread on /archiv/:year/:month/t:tid", %{conn: conn} do
    thread = insert(:thread, tid: 1)
    message = insert(:message, forum: thread.forum, thread: thread)
    conn = get(conn, "/archiv/#{thread.created_at.year}/#{thread.created_at.month}/t1")
    assert redirected_to(conn) == CforumWeb.Views.Helpers.Path.message_path(conn, :show, thread, message)
  end

  test "redirects to thread on /archiv/:year_:no/:month/t:tid", %{conn: conn} do
    thread = insert(:thread, tid: 1)
    message = insert(:message, forum: thread.forum, thread: thread)
    conn = get(conn, "/archiv/#{thread.created_at.year}_2/#{thread.created_at.month}/t1")
    assert redirected_to(conn) == CforumWeb.Views.Helpers.Path.message_path(conn, :show, thread, message)
  end

  test "shows a list of threads on /archiv/:year/:month/t:tid with multiple threads found", %{conn: conn} do
    thread = insert(:thread, tid: 1)
    thread2 = insert(:thread, tid: 1)
    insert(:message, forum: thread.forum, thread: thread, subject: "thread 1")
    insert(:message, forum: thread2.forum, thread: thread2, subject: "thread 2")

    conn = get(conn, "/archiv/#{thread.created_at.year}_2/#{thread.created_at.month}/t1")
    assert html_response(conn, 200) =~ ~r/thread 1/
    assert html_response(conn, 200) =~ ~r/thread 2/
  end

  test "fails on /archiv/:year/:month/t:tid with not existing tid", %{conn: conn} do
    assert_error_sent(404, fn -> get(conn, "/archiv/1999/1/t1") end)
  end

  test "redirects to message on /m:mid", %{conn: conn} do
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum)
    conn = get(conn, "/m#{message.message_id}")
    assert redirected_to(conn) == CforumWeb.Views.Helpers.Path.message_path(conn, :show, thread, message)
  end

  test "fails on /m:mid with non-existant mid", %{conn: conn} do
    assert_error_sent(404, fn -> get(conn, "/m0") end)
  end
end
