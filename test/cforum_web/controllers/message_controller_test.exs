defmodule CforumWeb.MessageControllerTest do
  use CforumWeb.ConnCase

  describe "show" do
    setup do
      forum = insert(:public_forum)
      thread = insert(:thread, forum: forum)
      message = insert(:message, thread: thread, forum: forum)
      message1 = insert(:message, subject: "2nd level message", thread: thread, forum: forum, parent: message)

      {:ok, forum: forum, thread: thread, message: message, message1: message1}
    end

    test "read mode parameter with thread shows thread view", %{conn: conn, thread: t, message: m} do
      conn = get(conn, Path.message_path(conn, :show, t, m, rm: "thread"))
      assert html_response(conn, 200) =~ ~r/class="messages thread-view/
    end

    test "read mode parameter with nested shows nested view", %{conn: conn, thread: t, message: m} do
      conn = get(conn, Path.message_path(conn, :show, t, m, rm: "nested"))
      assert html_response(conn, 200) =~ ~r/class="messages nested-view/
    end

    test "read mode cookie with thread shows thread-view", %{conn: conn, thread: t, message: m} do
      conn =
        conn
        |> Phoenix.ConnTest.put_req_cookie("cf_readmode", "thread")
        |> get(Path.message_path(conn, :show, t, m))

      assert html_response(conn, 200) =~ ~r/class="messages thread-view/
    end

    test "read mode cookie with nested shows nested-view", %{conn: conn, thread: t, message: m} do
      conn =
        conn
        |> Phoenix.ConnTest.put_req_cookie("cf_readmode", "nested")
        |> get(Path.message_path(conn, :show, t, m))

      assert html_response(conn, 200) =~ ~r/class="messages nested-view/
    end

    test "config with read mode thread shows thread-view", %{conn: conn, thread: t, message: m} do
      insert(:setting, options: %{"standard_view" => "thread"})
      conn = get(conn, Path.message_path(conn, :show, t, m))
      assert html_response(conn, 200) =~ ~r/class="messages thread-view/
    end

    test "config with read mode nested shows nested-view", %{conn: conn, thread: t, message: m} do
      insert(:setting, options: %{"standard_view" => "nested"})
      conn = get(conn, Path.message_path(conn, :show, t, m, rm: "nested"))
      assert html_response(conn, 200) =~ ~r/class="messages nested-view/
    end

    test "shows the whole thread in nested read mode", %{conn: conn, thread: t, message: m, message1: m1} do
      conn = get(conn, Path.message_path(conn, :show, t, m))
      assert html_response(conn, 200) =~ "id=\"m#{m.message_id}\""
      assert html_response(conn, 200) =~ "id=\"m#{m1.message_id}\""
    end

    test "shows a message in thread read mode", %{conn: conn, thread: thread, message: message, message1: message1} do
      conn = get(conn, Path.message_path(conn, :show, thread, message, rm: "thread"))
      assert html_response(conn, 200) =~ "id=\"m#{message.message_id}\""
      refute html_response(conn, 200) =~ "id=\"m#{message1.message_id}\""
    end
  end

  describe "new" do
    setup do
      forum = insert(:public_forum)
      thread = insert(:thread, forum: forum)
      message = insert(:message, thread: thread, forum: forum)

      {:ok, forum: forum, thread: thread, message: message}
    end

    test "get /new shows the answer form", %{conn: conn, thread: t, message: m} do
      conn = get(conn, Path.message_path(conn, :new, t, m))
      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)
    end

    test "get /new with ?with_quote=yes shows new answer form w/ quote", %{conn: conn, thread: t, message: m} do
      conn = get(conn, Path.message_path(conn, :new, t, m, with_quote: "yes"))
      assert html_response(conn, 200) =~ ~r/<textarea[^>]+id="message_input"[^>]*>\s*&gt;/s
    end

    test "get /new with ?with_quote=no shows new answer form w/o quote", %{conn: conn, thread: t, message: m} do
      conn = get(conn, Path.message_path(conn, :new, t, m, with_quote: "no"))
      assert html_response(conn, 200) =~ ~r{<textarea[^>]+id="message_input"[^>]*>\s*</textarea>}s
    end

    test "get /new with quote_by_default=no doesn't quote", %{conn: conn, thread: t, message: m} do
      insert(:setting, options: %{"quote_by_default" => "no"})
      conn = get(conn, Path.message_path(conn, :new, t, m))
      assert html_response(conn, 200) =~ ~r{<textarea[^>]+id="message_input"[^>]*>\s*</textarea>}s
    end

    test "get /new with quote_by_default=yes shows new answer form w/ quote", %{conn: conn, thread: t, message: m} do
      insert(:setting, options: %{"quote_by_default" => "yes"})
      conn = get(conn, Path.message_path(conn, :new, t, m))
      assert html_response(conn, 200) =~ ~r/<textarea[^>]+id="message_input"[^>]*>\s*&gt;/s
    end
  end

  describe "create" do
    setup do
      forum = insert(:public_forum)
      thread = insert(:thread, forum: forum)
      message = insert(:message, thread: thread, forum: forum)
      user = insert(:user)
      tag = insert(:tag)

      {:ok, forum: forum, thread: thread, message: message, user: user, tag: tag}
    end

    test "post /new creates a new answer", %{conn: conn, thread: t, message: m, tag: tag} do
      conn = post(conn, Path.message_path(conn, :new, t, m), message: params_for(:message, tags: [tag.tag_name]))

      assert %{curr_forum: f, year: y, month: m, day: d, slug: s, mid: mid} = cf_redirected_params(conn)
      assert redirected_to(conn) == "/#{f}/#{y}/#{m}/#{d}/#{s}/#{mid}#m#{mid}"
    end

    test "post /new creates a new answer with user_id set", %{conn: conn, thread: t, message: m, user: user, tag: tag} do
      conn =
        login(conn, user)
        |> post(Path.message_path(conn, :new, t, m), message: params_for(:message, tags: [tag.tag_name]))

      assert %{curr_forum: _f, year: _y, month: _m, day: _d, slug: _s, mid: mid} = cf_redirected_params(conn)

      msg = Cforum.Messages.get_message!(mid)
      assert msg.user_id == user.user_id
    end

    test "post /new forbids posting with a registered author name", %{conn: conn, thread: t, message: m, user: user} do
      conn = post(conn, Path.message_path(conn, :new, t, m), message: params_for(:message, author: user.username))
      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)
    end

    test "name checks ignore spaces", %{conn: conn, thread: t, message: m, user: user} do
      conn =
        post(conn, Path.message_path(conn, :new, t, m), message: params_for(:message, author: user.username <> " "))

      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)

      conn =
        post(conn, Path.message_path(conn, :new, t, m), message: params_for(:message, author: " " <> user.username))

      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)

      conn =
        post(conn, Path.message_path(conn, :new, t, m), message: params_for(:message, author: " " <> user.username))

      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)

      conn =
        post(conn, Path.message_path(conn, :new, t, m), message: params_for(:message, author: user.username <> " "))

      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)

      conn =
        post(conn, Path.message_path(conn, :new, t, m), message: params_for(:message, author: user.username <> "\r\n"))

      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)

      conn =
        post(conn, Path.message_path(conn, :new, t, m), message: params_for(:message, author: "\r\n" <> user.username))

      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)
    end

    test "post to /new with ?preview=yes set renders the preview", %{conn: conn, thread: t, message: m} do
      conn = post(conn, Path.message_path(conn, :new, t, m), message: params_for(:message), preview: "yes")
      assert html_response(conn, 200) =~ ~r/<article class="cf-thread-message preview/
    end

    test "posting as a user doesn't require a name", %{conn: conn, thread: t, message: m, user: user, tag: tag} do
      conn =
        login(conn, user)
        |> post(Path.message_path(conn, :new, t, m),
          message: Map.delete(params_for(:message, tags: [tag.tag_name]), :author)
        )

      assert %{curr_forum: _f, year: _y, month: _m, day: _d, slug: _s, mid: _mid} = cf_redirected_params(conn)
    end

    test "posting anonymous requires a name", %{conn: conn, thread: t, message: m} do
      conn = post(conn, Path.message_path(conn, :new, t, m), message: Map.delete(params_for(:message), :author))
      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)
    end

    test "posting requires a subject", %{conn: conn, thread: t, message: m} do
      conn = post(conn, Path.message_path(conn, :new, t, m), message: Map.delete(params_for(:message), :subject))
      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)
    end

    test "posting requires content", %{conn: conn, thread: t, message: m} do
      conn = post(conn, Path.message_path(conn, :new, t, m), message: Map.delete(params_for(:message), :content))
      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)
    end
  end
end
