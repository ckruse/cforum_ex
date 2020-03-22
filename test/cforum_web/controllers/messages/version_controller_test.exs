defmodule CforumWeb.Messages.VersionControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_tests]

  describe "show" do
    test "renders for messages w/o any version", %{conn: conn, thread: thread, message: message} do
      conn = get(conn, Path.message_version_path(conn, :index, thread, message))
      assert html_response(conn, 200) =~ gettext("versions of message „%{subject}“", subject: message.subject)
    end

    test "renders for messages with versions", %{conn: conn, thread: thread, message: message} do
      insert(:message_version, message: message)
      conn = get(conn, Path.message_version_path(conn, :index, thread, message))
      assert html_response(conn, 200) =~ gettext("versions of message „%{subject}“", subject: message.subject)
    end
  end

  describe "delete" do
    test "deletes a message version", %{conn: conn, thread: thread, message: message} do
      version = insert(:message_version, message: message)
      conn = delete(conn, Path.message_version_path(conn, :delete, thread, message, version))
      assert redirected_to(conn) == Path.message_version_path(conn, :index, thread, message)
      assert get_flash(conn, :info) == gettext("Message version deleted successfully.")
    end
  end

  defp setup_tests(%{conn: conn}) do
    user = insert(:user, admin: true)

    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread, user: user)
    {:ok, user: user, conn: login(conn, user), thread: thread, message: message, forum: forum}
  end
end
