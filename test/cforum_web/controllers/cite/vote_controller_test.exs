defmodule CforumWeb.Cite.VoteControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Cites

  setup [:create_cite]

  describe "vote" do
    setup [:setup_login]

    test "votes down for a cite", %{conn: conn, cite: cite, user: user} do
      conn = post(conn, cite_path(conn, :vote, cite), %{type: "down"})
      cite = Cites.get_cite!(cite.cite_id)

      assert redirected_to(conn) == cite_path(conn, :show, cite)
      assert Cites.downvoted?(cite, user)
    end

    test "votes up for a cite", %{conn: conn, cite: cite, user: user} do
      conn = post(conn, cite_path(conn, :vote, cite), %{type: "up"})
      cite = Cites.get_cite!(cite.cite_id)

      assert redirected_to(conn) == cite_path(conn, :show, cite)
      assert Cites.upvoted?(cite, user)
    end

    test "changes a vote for a cite", %{conn: conn, cite: cite, user: user} do
      insert(:cite_vote, user: user, cite: cite)

      conn = post(conn, cite_path(conn, :vote, cite), %{type: "down"})
      cite = Cites.get_cite!(cite.cite_id)

      assert redirected_to(conn) == cite_path(conn, :show, cite)
      assert Cites.downvoted?(cite, user)
      refute Cites.upvoted?(cite, user)
    end

    test "takes back a vote for a cite", %{conn: conn, cite: cite, user: user} do
      insert(:cite_vote, user: user, cite: cite)

      conn = post(conn, cite_path(conn, :vote, cite), %{type: "up"})
      cite = Cites.get_cite!(cite.cite_id)

      assert redirected_to(conn) == cite_path(conn, :show, cite)
      refute Cites.downvoted?(cite, user)
      refute Cites.upvoted?(cite, user)
    end
  end

  describe "access rights" do
    test "anonymous mustn't vote", %{conn: conn, cite: cite} do
      assert_error_sent(403, fn -> post(conn, cite_path(conn, :vote, cite), type: "down") end)
    end

    test "logged in user may vote", %{conn: conn, cite: cite} do
      user = insert(:user)

      conn =
        conn
        |> login(user)
        |> post(cite_path(conn, :vote, cite), type: "down")

      assert redirected_to(conn) == cite_path(conn, :show, cite)
    end

    test "archived cites may not be voted", %{conn: conn} do
      cite = insert(:cite, archived: true)
      user = insert(:user, admin: true)

      assert_error_sent(403, fn ->
        conn
        |> login(user)
        |> post(cite_path(conn, :vote, cite), type: "down")
      end)
    end
  end

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    {:ok, user: user, conn: login(conn, user)}
  end

  defp create_cite(_) do
    cite = insert(:cite)
    {:ok, cite: cite}
  end
end
