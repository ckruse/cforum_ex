defmodule CforumWeb.ModerationControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_login]

  describe "index" do
    test "lists all entries", %{conn: conn, message: message} do
      insert(:moderation_queue_entry, message: message)
      conn = get(conn, Routes.moderation_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("moderation")
    end

    test "shows a „none found“ message", %{conn: conn} do
      conn = get(conn, Routes.moderation_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("No moderation queue entries found")
    end

    test "lists all open entries", %{conn: conn, message: message} do
      insert(:moderation_queue_entry, message: message)
      conn = get(conn, Routes.moderation_path(conn, :index_open))
      assert html_response(conn, 200) =~ gettext("moderation")
    end

    test "index_open shows a „none found“ message", %{conn: conn} do
      conn = get(conn, Routes.moderation_path(conn, :index_open))
      assert html_response(conn, 200) =~ gettext("No moderation queue entries found")
    end
  end

  describe "show moderation queue entry" do
    setup [:create_moderation_queue_entry]

    test "shows chosen resource", %{conn: conn, entry: entry} do
      conn = get(conn, Routes.moderation_path(conn, :show, entry))
      assert html_response(conn, 200) =~ gettext("moderation")
    end
  end

  describe "edit moderation queue entry" do
    setup [:create_moderation_queue_entry]

    test "renders form for editing chosen entry", %{conn: conn, entry: entry} do
      conn = get(conn, Routes.moderation_path(conn, :edit, entry))
      assert html_response(conn, 200) =~ gettext("moderation")
    end
  end

  describe "update moderation queue entry" do
    setup [:create_moderation_queue_entry]

    test "redirects when data is valid", %{conn: conn, entry: entry} do
      conn =
        put(
          conn,
          Routes.moderation_path(conn, :update, entry),
          moderation_queue_entry: %{resolution: "none", resolution_action: "none"}
        )

      assert redirected_to(conn) == Routes.moderation_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn, entry: entry} do
      conn =
        put(
          conn,
          Routes.moderation_path(conn, :update, entry),
          moderation_queue_entry: %{resolution: nil, resolution_action: nil}
        )

      assert html_response(conn, 200) =~ gettext("moderation")
    end
  end

  defp create_moderation_queue_entry(%{message: message}),
    do: {:ok, entry: insert(:moderation_queue_entry, message: message)}

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    forum = insert(:forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    {:ok, user: user, conn: login(conn, user), message: message}
  end
end
