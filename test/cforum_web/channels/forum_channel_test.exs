defmodule CforumWeb.ForumChannelTest do
  use CforumWeb.ChannelCase

  setup do
    forum = insert(:public_forum)
    priv_forum = insert(:forum)
    user = insert(:user, admin: true)

    {:ok, forum: forum, user: user, priv_forum: priv_forum}
  end

  test "can't join a private forum", %{priv_forum: forum} do
    assert {:error, %{reason: "unauthorized"}} =
             socket(CforumWeb.UserSocket, "user_id", %{})
             |> subscribe_and_join(CforumWeb.ForumChannel, "forum:#{forum.forum_id}")
  end

  test "joins a public forum", %{forum: forum} do
    {:ok, _, _socket} =
      socket(CforumWeb.UserSocket, "user_id", %{})
      |> subscribe_and_join(CforumWeb.ForumChannel, "forum:#{forum.forum_id}")
  end

  test "admin joins a private forum", %{priv_forum: forum, user: user} do
    {:ok, _, _socket} =
      socket(CforumWeb.UserSocket, "user_id", %{current_user: user})
      |> subscribe_and_join(CforumWeb.ForumChannel, "forum:#{forum.forum_id}")
  end

  test "broadcasts are pushed to the client", %{forum: forum} do
    {:ok, _, socket} =
      socket(CforumWeb.UserSocket, "user_id", %{})
      |> subscribe_and_join(CforumWeb.ForumChannel, "forum:#{forum.forum_id}")

    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
