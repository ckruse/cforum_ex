defmodule CforumWeb.Cite.VoteControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Cites

  describe "vote" do
    setup [:create_cite]

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

  defp create_cite(%{conn: conn}) do
    cite = insert(:cite)
    user = build(:user) |> as_admin |> insert
    {:ok, cite: cite, user: user, conn: login(conn, user)}
  end
end
