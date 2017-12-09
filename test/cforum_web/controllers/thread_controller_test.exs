defmodule CforumWeb.ThreadControllerTest do
  use CforumWeb.ConnCase

  test "lists threads on index with /<forum>", %{conn: conn} do
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum)

    forum1 = insert(:public_forum)
    thread1 = insert(:thread, forum: forum1)
    message1 = insert(:message, thread: thread1, forum: forum1)

    conn = get(conn, forum_path(conn, :index, forum.slug))

    assert html_response(conn, 200) =~ message.subject
    refute html_response(conn, 200) =~ message1.subject

    conn = get(conn, forum_path(conn, :index, forum1.slug))

    refute html_response(conn, 200) =~ message.subject
    assert html_response(conn, 200) =~ message1.subject
  end

  test "lists threads on index with /all", %{conn: conn} do
    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum)

    forum1 = insert(:public_forum)
    thread1 = insert(:thread, forum: forum1)
    message1 = insert(:message, thread: thread1, forum: forum1)

    conn = get(conn, forum_path(conn, :index, "all"))

    assert html_response(conn, 200) =~ ~r/<article class="thread/
    assert html_response(conn, 200) =~ message.subject
    assert html_response(conn, 200) =~ message1.subject
  end
end
