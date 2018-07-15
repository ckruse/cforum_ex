defmodule CforumWeb.Messages.FlagControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_tests]

  alias Cforum.Forums.ModerationQueue

  test "shows a new form", %{conn: conn, thread: thread, message: message} do
    conn = get(conn, flag_message_path(conn, thread, message))

    assert html_response(conn, 200) =~
             gettext("flag message %{subject} by %{author}", subject: message.subject, author: message.author)
  end

  test "flags a message", %{conn: conn, thread: thread, message: message} do
    conn =
      post(
        conn,
        flag_message_path(conn, thread, message),
        moderation_queue_entry: %{reason: "off-topic", message_id: message.message_id}
      )

    assert redirected_to(conn) == message_path(conn, :show, thread, message)
    assert get_flash(conn, :info) == gettext("Message has successfully been flagged.")
  end

  test "flags an already flagged message", %{conn: conn, thread: thread, message: message} do
    ModerationQueue.create_or_update_entry(message, %{"reason" => "off-topic", "message_id" => message.message_id})

    conn =
      post(
        conn,
        flag_message_path(conn, thread, message),
        moderation_queue_entry: %{reason: "off-topic", message_id: message.message_id}
      )

    assert redirected_to(conn) == message_path(conn, :show, thread, message)
    assert get_flash(conn, :info) == gettext("Message has successfully been flagged.")
  end

  test "shows a new form on invalid data", %{conn: conn, thread: thread, message: message} do
    conn =
      post(conn, flag_message_path(conn, thread, message), moderation_queue_entry: %{message_id: message.message_id})

    assert html_response(conn, 200) =~
             gettext("flag message %{subject} by %{author}", subject: message.subject, author: message.author)
  end

  defp setup_tests(%{conn: conn}) do
    user = build(:user) |> insert

    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    {:ok, user: user, conn: login(conn, user), thread: thread, message: message, forum: forum}
  end
end
