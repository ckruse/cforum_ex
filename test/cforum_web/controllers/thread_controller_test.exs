defmodule CforumWeb.ThreadControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Threads
  alias Cforum.Messages

  setup do
    forum = insert(:public_forum)
    tag = insert(:tag)
    {:ok, forum: forum, tag: tag}
  end

  describe "index" do
    test "lists threads on index with /<forum>", %{conn: conn, forum: forum} do
      thread = insert(:thread, forum: forum)
      message = insert(:message, thread: thread, forum: forum)

      forum1 = insert(:public_forum)
      thread1 = insert(:thread, forum: forum1)
      message1 = insert(:message, thread: thread1, forum: forum1)

      conn = get(conn, Path.forum_path(conn, :index, forum.slug))

      assert html_response(conn, 200) =~ message.subject
      refute html_response(conn, 200) =~ message1.subject

      conn = get(conn, Path.forum_path(conn, :index, forum1.slug))

      refute html_response(conn, 200) =~ message.subject
      assert html_response(conn, 200) =~ message1.subject
    end

    test "lists threads on index with /all", %{conn: conn, forum: forum} do
      thread = insert(:thread, forum: forum)
      message = insert(:message, thread: thread, forum: forum)

      forum1 = insert(:public_forum)
      thread1 = insert(:thread, forum: forum1)
      message1 = insert(:message, thread: thread1, forum: forum1)

      conn = get(conn, Path.forum_path(conn, :index, "all"))

      assert html_response(conn, 200) =~ ~r/<article class="cf-thread/
      assert html_response(conn, 200) =~ message.subject
      assert html_response(conn, 200) =~ message1.subject
    end
  end

  describe "new" do
    test "renders form", %{conn: conn, forum: forum} do
      conn = get(conn, Path.thread_path(conn, :new, forum))
      assert html_response(conn, 200) =~ gettext("new thread")
    end

    test "renders form for /all with forum select", %{conn: conn} do
      conn = get(conn, Path.thread_path(conn, :new, "all"))
      assert html_response(conn, 200) =~ gettext("new thread")
      assert html_response(conn, 200) =~ ~r/name="message\[forum_id\]"/
    end

    test "renders form for a forum w/o forum select", %{conn: conn, forum: forum} do
      conn = get(conn, Path.thread_path(conn, :new, forum))
      assert html_response(conn, 200) =~ gettext("new thread")
      refute html_response(conn, 200) =~ ~r/name="message\[forum_id\]"/
    end
  end

  describe "create" do
    test "renders a preview", %{conn: conn, forum: forum} do
      conn = post(conn, Path.thread_path(conn, :new, forum), message: params_for(:message), preview: "yes")
      assert html_response(conn, 200) =~ ~r/<article class="cf-thread-message preview/
    end

    test "renders a preview in /all", %{conn: conn, forum: forum} do
      conn =
        post(
          conn,
          Path.thread_path(conn, :new, nil),
          message: params_for(:message, forum_id: forum.forum_id),
          preview: "yes"
        )

      assert html_response(conn, 200) =~ ~r/<article class="cf-thread-message preview/
    end

    test "creates a thread", %{conn: conn, forum: forum, tag: tag} do
      conn =
        post(conn, Path.thread_path(conn, :new, forum),
          message: params_for(:message, forum_id: nil, tags: [tag.tag_name])
        )

      assert %{curr_forum: f, year: y, month: m, day: d, slug: s, mid: mid} = cf_redirected_params(conn)
      assert redirected_to(conn) == "/#{f}/#{y}/#{m}/#{d}/#{s}/#{mid}#m#{mid}"
    end

    test "creates a thread in /all", %{conn: conn, forum: forum, tag: tag} do
      conn =
        post(conn, Path.thread_path(conn, :new, nil),
          message: params_for(:message, forum_id: forum.forum_id, tags: [tag.tag_name])
        )

      assert %{curr_forum: f, year: y, month: m, day: d, slug: s, mid: mid} = cf_redirected_params(conn)
      assert redirected_to(conn) == "/#{f}/#{y}/#{m}/#{d}/#{s}/#{mid}#m#{mid}"
    end

    test "creates a thread with forum_id from path", %{conn: conn, forum: forum, tag: tag} do
      f1 = insert(:public_forum)

      conn =
        post(conn, Path.thread_path(conn, :new, forum),
          message: params_for(:message, forum_id: f1.forum_id, tags: [tag.tag_name])
        )

      assert %{curr_forum: f, year: y, month: m, day: d, slug: s, mid: mid} = cf_redirected_params(conn)
      assert redirected_to(conn) == "/#{f}/#{y}/#{m}/#{d}/#{s}/#{mid}#m#{mid}"
      assert f == forum.slug

      t = Threads.get_thread_by_slug!(forum, nil, "/#{y}/#{m}/#{d}/#{s}")
      assert t.forum_id == forum.forum_id
      m = Messages.get_message!(mid)
      assert m.forum_id == forum.forum_id
    end

    test "does not create a thread with missing params", %{conn: conn, forum: forum} do
      conn = post(conn, Path.thread_path(conn, :new, nil), message: params_for(:message, forum_id: nil))
      assert html_response(conn, 200) =~ gettext("new thread")

      conn = post(conn, Path.thread_path(conn, :new, forum), message: params_for(:message, subject: ""))
      assert html_response(conn, 200) =~ gettext("new thread")

      conn = post(conn, Path.thread_path(conn, :new, forum), message: params_for(:message, content: ""))
      assert html_response(conn, 200) =~ gettext("new thread")
    end
  end
end
