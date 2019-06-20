defmodule CforumWeb.Messages.AcceptControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_tests]

  alias Cforum.Messages

  test "accepts an answer", %{conn: conn, forum: forum, thread: thread, message: message} do
    conn = post(conn, Path.accept_message_path(conn, thread, message), f: forum.slug, r: "message")
    assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
    assert get_flash(conn, :info) == gettext("Message has successfully been accepted as a solving answer")
  end

  test "responds with 403 on an already accepted answer", %{conn: conn, user: user, thread: thread, message: message} do
    Messages.accept_message(message, user, 15)
    conn = post(conn, Path.accept_message_path(conn, thread, message))
    assert conn.status == 403
  end

  test "unaccepts an answer", %{conn: conn, user: user, forum: forum, thread: thread, message: message} do
    Messages.accept_message(message, user, 15)
    conn = post(conn, Path.unaccept_message_path(conn, thread, message), f: forum.slug, r: "message")
    assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
    assert get_flash(conn, :info) == gettext("Message has successfully been unaccepted as a solving answer")
  end

  test "responds with 403 on an not accepted answer", %{conn: conn, thread: thread, message: message} do
    conn = post(conn, Path.unaccept_message_path(conn, thread, message))
    assert conn.status == 403
  end

  defp setup_tests(%{conn: conn}) do
    user = build(:user) |> as_admin() |> insert

    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    {:ok, user: user, conn: login(conn, user), thread: thread, message: message, forum: forum}
  end
end
