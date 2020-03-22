defmodule CforumWeb.Messages.RetagControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Messages.Message

  setup [:setup_tests]

  describe "edit" do
    test "renders a form for an existing message", %{conn: conn, thread: thread, message: message} do
      conn = get(conn, Path.message_path(conn, :retag, thread, message))
      assert html_response(conn, 200) =~ gettext("Retag message “%{subject}”", subject: message.subject)
    end

    test "renders a 404 when message does not exist", %{conn: conn, thread: thread} do
      assert_error_sent(404, fn -> get(conn, Path.message_path(conn, :retag, thread, %Message{message_id: -123})) end)
    end
  end

  describe "update" do
    test "retags a single message", %{conn: conn, thread: thread, message: message} do
      conn = post(conn, Path.message_path(conn, :retag, thread, message), message: %{tags: ["foo", "bar"]})
      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Message has successfully been retagged.")
    end

    test "retags message and children", %{conn: conn, thread: thread, message: message, forum: forum} do
      tag = insert(:tag, tag_name: "foo-bar-tag")
      message1 = insert(:message, thread: thread, parent: message, tags: [tag], forum: forum)

      conn =
        post(conn, Path.message_path(conn, :retag, thread, message),
          message: %{tags: ["foo", "bar"]},
          retag_children: "yes"
        )

      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Message has successfully been retagged.")

      conn = get(conn, Path.message_path(conn, :show, thread, message1))
      refute html_response(conn, 200) =~ ~r/foo-bar-tag/
    end

    test "doesn't retag on non-existing tag", %{conn: conn, thread: thread, message: message} do
      conn = post(conn, Path.message_path(conn, :retag, thread, message), message: %{tags: ["nonexistant"]})
      assert html_response(conn, 200)
    end

    test "retags with non-existing tag when user may create", %{
      conn: conn,
      thread: thread,
      message: message,
      user: user
    } do
      badge = insert(:badge, badge_type: "create_tag")
      insert(:badge_user, user: user, badge: badge)

      conn =
        conn
        |> login(user)
        |> post(Path.message_path(conn, :retag, thread, message), message: %{tags: ["nonexistant"]})

      assert redirected_to(conn) == Path.message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Message has successfully been retagged.")
    end
  end

  defp setup_tests(%{conn: conn}) do
    badge = insert(:badge, badge_type: "retag")
    user = insert(:user) |> with_badge(badge)

    insert(:tag, tag_name: "foo")
    insert(:tag, tag_name: "bar")

    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    {:ok, user: user, conn: login(conn, user), thread: thread, message: message, forum: forum}
  end
end
