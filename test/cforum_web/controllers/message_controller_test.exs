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
      conn = get(conn, message_path(conn, t, m, :show, rm: "thread"))
      assert html_response(conn, 200) =~ ~r/class="messages thread-view/
    end

    test "read mode parameter with nested shows nested view", %{conn: conn, thread: t, message: m} do
      conn = get(conn, message_path(conn, t, m, :show, rm: "nested"))
      assert html_response(conn, 200) =~ ~r/class="messages nested-view/
    end

    test "read mode cookie with thread shows thread-view", %{conn: conn, thread: t, message: m} do
      conn =
        conn
        |> Phoenix.ConnTest.put_req_cookie("cf_readmode", "thread")
        |> get(message_path(conn, t, m, :show))

      assert html_response(conn, 200) =~ ~r/class="messages thread-view/
    end

    test "read mode cookie with nested shows nested-view", %{conn: conn, thread: t, message: m} do
      conn =
        conn
        |> Phoenix.ConnTest.put_req_cookie("cf_readmode", "nested")
        |> get(message_path(conn, t, m, :show))

      assert html_response(conn, 200) =~ ~r/class="messages nested-view/
    end

    test "config with read mode thread shows thread-view", %{conn: conn, thread: t, message: m} do
      insert(:setting, options: %{"standard_view" => "thread"})
      conn = get(conn, message_path(conn, t, m, :show))
      assert html_response(conn, 200) =~ ~r/class="messages thread-view/
    end

    test "config with read mode nested shows nested-view", %{conn: conn, thread: t, message: m} do
      insert(:setting, options: %{"standard_view" => "nested"})
      conn = get(conn, message_path(conn, t, m, :show, rm: "nested"))
      assert html_response(conn, 200) =~ ~r/class="messages nested-view/
    end

    test "shows the whole thread in nested read mode", %{conn: conn, thread: t, message: m, message1: m1} do
      conn = get(conn, message_path(conn, t, m, :show))
      assert html_response(conn, 200) =~ "id=\"m#{m.message_id}\""
      assert html_response(conn, 200) =~ "id=\"m#{m1.message_id}\""
    end

    test "shows a message in thread read mode", %{conn: conn, thread: thread, message: message, message1: message1} do
      conn = get(conn, message_path(conn, thread, message, :show, rm: "thread"))
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
      conn = get(conn, message_path(conn, t, m, :new))
      assert html_response(conn, 200) =~ gettext("new answer to %{name}", name: m.author)
    end

    test "get /new with ?with_quote=yes shows new answer form w/ quote", %{conn: conn, thread: t, message: m} do
      conn = get(conn, message_path(conn, t, m, :new, with_quote: "yes"))
      assert html_response(conn, 200) =~ ~r/<textarea[^>]+id="message_input"[^>]*>\s*&gt;/s
    end

    test "get /new with ?with_quote=no shows new answer form w/o quote", %{conn: conn, thread: t, message: m} do
      conn = get(conn, message_path(conn, t, m, :new, with_quote: "no"))
      assert html_response(conn, 200) =~ ~r{<textarea[^>]+id="message_input"[^>]*>\s*</textarea>}s
    end

    test "get /new with quote_by_default=no doesn't quote", %{conn: conn, thread: t, message: m} do
      insert(:setting, options: %{"quote_by_default" => "no"})
      conn = get(conn, message_path(conn, t, m, :new))
      assert html_response(conn, 200) =~ ~r{<textarea[^>]+id="message_input"[^>]*>\s*</textarea>}s
    end

    test "get /new with quote_by_default=yes shows new answer form w/ quote", %{conn: conn, thread: t, message: m} do
      insert(:setting, options: %{"quote_by_default" => "yes"})
      conn = get(conn, message_path(conn, t, m, :new))
      assert html_response(conn, 200) =~ ~r/<textarea[^>]+id="message_input"[^>]*>\s*&gt;/s
    end
  end
end
