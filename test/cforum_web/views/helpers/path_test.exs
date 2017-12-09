defmodule CforumWeb.Views.Helpers.PathTest do
  use CforumWeb.ConnCase, async: true

  test "thread_path/2 generates thread path from slug", %{conn: conn} do
    t = build(:thread)
    assert thread_path(conn, t) == "/#{t.forum.slug}#{t.slug}"
  end

  test "thread_path/3 generates thread path with query string", %{conn: conn} do
    t = build(:thread)

    assert thread_path(conn, t, a: "b", c: 1, d: false, e: true, "baz bar": "foo bar") ==
             "/#{t.forum.slug}#{t.slug}?a=b&c=1&d=false&e=true&baz+bar=foo+bar"
  end

  describe "message_path" do
    test "message_path/3 generates a :show path", %{conn: conn} do
      f = insert(:forum)
      t = insert(:thread, forum: f)
      m = insert(:message, thread: t, forum: f)

      assert message_path(conn, t, m) == "/#{f.slug}#{t.slug}/#{m.message_id}#m#{m.message_id}"
    end

    test "message_path/5 generates a query string", %{conn: conn} do
      f = insert(:forum)
      t = insert(:thread, forum: f)
      m = insert(:message, thread: t, forum: f)

      assert message_path(conn, t, m, :show, a: "b", c: "d") ==
               "/#{f.slug}#{t.slug}/#{m.message_id}?a=b&c=d#m#{m.message_id}"
    end

    test "message_path/4 with :new generates a /new path", %{conn: conn} do
      f = insert(:forum)
      t = insert(:thread, forum: f)
      m = insert(:message, thread: t, forum: f)

      assert message_path(conn, t, m, :new) == "/#{f.slug}#{t.slug}/#{m.message_id}/new"
    end

    test "message_path/5 with :new generates a /new path with a query string", %{conn: conn} do
      f = insert(:forum)
      t = insert(:thread, forum: f)
      m = insert(:message, thread: t, forum: f)

      assert message_path(conn, t, m, :new, a: "b", c: "d") == "/#{f.slug}#{t.slug}/#{m.message_id}/new?a=b&c=d"
    end
  end
end
