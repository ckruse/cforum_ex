defmodule CforumWeb.ArchiveControllerTest do
  use CforumWeb.ConnCase

  setup do
    {:ok, forum: insert(:public_forum)}
  end

  test "/forum/archive lists years", %{conn: conn, forum: forum} do
    thread = insert(:thread, forum: forum)
    insert(:message, thread: thread, forum: forum)

    conn = get(conn, "/#{forum.slug}/archive")
    assert html_response(conn, 200) =~ Integer.to_string(thread.created_at.year)
  end

  test "/forum/archive doesn't fail when there are no years", %{conn: conn, forum: forum} do
    conn = get(conn, "/#{forum.slug}/archive")
    assert html_response(conn, 200)
  end

  test "/all/archive lists years", %{conn: conn, forum: forum} do
    thread = insert(:thread, forum: forum)
    insert(:message, thread: thread, forum: forum)

    conn = get(conn, "/all/archive")
    assert html_response(conn, 200) =~ Integer.to_string(thread.created_at.year)
  end

  test "/all/archive doesn't fail when there are no years", %{conn: conn} do
    conn = get(conn, "/all/archive")
    assert html_response(conn, 200)
  end

  test "/forum/archive/year lists months", %{conn: conn, forum: forum} do
    thread = insert(:thread, forum: forum)
    insert(:message, thread: thread, forum: forum)

    conn = get(conn, "/#{forum.slug}/#{thread.created_at.year}")
    assert html_response(conn, 200) =~ Timex.format!(thread.created_at, "%B", :strftime)
  end

  test "/forum/archive/year doesn't fail when there are no months", %{conn: conn, forum: forum} do
    conn = get(conn, "/#{forum.slug}/1999")
    assert html_response(conn, 200)
  end

  test "/all/archive/year lists months", %{conn: conn, forum: forum} do
    thread = insert(:thread, forum: forum)
    insert(:message, thread: thread, forum: forum)

    conn = get(conn, "/all/#{thread.created_at.year}")
    assert html_response(conn, 200) =~ Timex.format!(thread.created_at, "%B", :strftime)
  end

  test "/all/archive/year doesn't fail when there are no months", %{conn: conn} do
    conn = get(conn, "/all/1999")
    assert html_response(conn, 200)
  end

  test "/forum/archive/year/month lists postings", %{conn: conn, forum: forum} do
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum)
    slug = thread.created_at |> Timex.lformat!("%Y/%b", "en", :strftime) |> String.downcase()

    conn = get(conn, "/#{forum.slug}/#{slug}")
    assert html_response(conn, 200) =~ message.subject
  end

  test "/forum/archive/year/month doesn't fail when there are no postings", %{conn: conn, forum: forum} do
    conn = get(conn, "/#{forum.slug}/1998/jan")
    assert html_response(conn, 200)
  end

  test "/all/archive/year/month lists postings", %{conn: conn, forum: forum} do
    thread = insert(:thread, forum: forum)
    message = insert(:message, thread: thread, forum: forum)
    slug = thread.created_at |> Timex.lformat!("%Y/%b", "en", :strftime) |> String.downcase()

    conn = get(conn, "/all/#{slug}")
    assert html_response(conn, 200) =~ message.subject
  end

  test "/all/year/month doesn't fail when there are no postings", %{conn: conn} do
    conn = get(conn, "/all/1998/jan")
    assert html_response(conn, 200)
  end
end
