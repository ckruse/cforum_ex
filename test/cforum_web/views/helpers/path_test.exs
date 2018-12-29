defmodule CforumWeb.Views.Helpers.PathTest do
  use CforumWeb.ConnCase, async: true

  test "Path.thread_path/2 generates thread path from slug", %{conn: conn} do
    t = build(:thread)
    assert Path.thread_path(conn, :show, t) == "/#{t.forum.slug}#{t.slug}"
  end

  test "Path.thread_path/3 generates thread path with query string", %{conn: conn} do
    t = build(:thread)

    assert Path.thread_path(conn, :show, t, a: "b", c: 1, d: false, e: true, "baz bar": "foo bar") ==
             "/#{t.forum.slug}#{t.slug}?a=b&c=1&d=false&e=true&baz+bar=foo+bar"
  end

  describe "Path.message_path" do
    test "Path.message_path/3 generates a :show path", %{conn: conn} do
      f = insert(:forum)
      t = insert(:thread, forum: f)
      m = insert(:message, thread: t, forum: f)

      assert Path.message_path(conn, :show, t, m) == "/#{f.slug}#{t.slug}/#{m.message_id}#m#{m.message_id}"
    end

    test "Path.message_path/5 generates a query string", %{conn: conn} do
      f = insert(:forum)
      t = insert(:thread, forum: f)
      m = insert(:message, thread: t, forum: f)

      assert Path.message_path(conn, :show, t, m, a: "b", c: "d") ==
               "/#{f.slug}#{t.slug}/#{m.message_id}?a=b&c=d#m#{m.message_id}"
    end

    test "Path.message_path/4 with :new generates a /new path", %{conn: conn} do
      f = insert(:forum)
      t = insert(:thread, forum: f)
      m = insert(:message, thread: t, forum: f)

      assert Path.message_path(conn, :new, t, m) == "/#{f.slug}#{t.slug}/#{m.message_id}/new"
    end

    test "Path.message_path/5 with :new generates a /new path with a query string", %{conn: conn} do
      f = insert(:forum)
      t = insert(:thread, forum: f)
      m = insert(:message, thread: t, forum: f)

      assert Path.message_path(conn, :new, t, m, a: "b", c: "d") == "/#{f.slug}#{t.slug}/#{m.message_id}/new?a=b&c=d"
    end
  end
end
