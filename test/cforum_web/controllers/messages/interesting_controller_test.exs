defmodule CforumWeb.Messages.InterestingControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_tests]

  alias Cforum.Messages.InterestingMessages

  describe "listing" do
    test "lists all interesting messages", %{conn: conn, user: user, message: message} do
      InterestingMessages.mark_message_interesting(user, message)
      conn = get(conn, Path.interesting_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("messages marked as interesting")
      assert html_response(conn, 200) =~ message.subject
    end

    test "doesn't list boring messages", %{conn: conn, message: message} do
      conn = get(conn, Path.interesting_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("messages marked as interesting")
      refute html_response(conn, 200) =~ message.subject
    end
  end

  describe "marking as interesting" do
    test "marks as interesting", %{conn: conn, forum: forum, thread: thread, message: message} do
      conn = post(conn, Path.message_path(conn, :interesting, thread, message), f: forum.slug, r: "message")
      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Message was successfully marked as interesting.")
    end

    test "responds with 403 on interesting messages", %{conn: conn, user: user, thread: thread, message: message} do
      InterestingMessages.mark_message_interesting(user, message)
      assert_error_sent(403, fn -> post(conn, Path.message_path(conn, :interesting, thread, message)) end)
    end
  end

  describe "marking as boring" do
    test "marks as boring", %{conn: conn, user: user, forum: forum, thread: thread, message: message} do
      InterestingMessages.mark_message_interesting(user, message)
      conn = post(conn, Path.message_path(conn, :boring, thread, message), f: forum.slug, r: "message")
      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Interesting mark was successfully removed.")
    end

    test "responds with 403 on already boring messages", %{conn: conn, thread: thread, message: message} do
      assert_error_sent(403, fn -> post(conn, Path.message_path(conn, :boring, thread, message)) end)
    end
  end

  defp setup_tests(%{conn: conn}) do
    user = build(:user) |> insert

    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    {:ok, user: user, conn: login(conn, user), thread: thread, message: message, forum: forum}
  end
end
