defmodule CforumWeb.UsersChannelTest do
  use CforumWeb.ChannelCase

  alias CforumWeb.UsersChannel

  setup do
    user = insert(:user)
    {:ok, user: user}
  end

  test "can join the lobby" do
    {:ok, _, _socket} =
      socket(CforumWeb.UserSocket, "user_id", %{})
      |> subscribe_and_join(UsersChannel, "users:lobby")
  end

  test "user can join own channel", %{user: user} do
    {:ok, _, _socket} =
      socket(CforumWeb.UserSocket, "user_id", %{current_user: user})
      |> subscribe_and_join(UsersChannel, "users:#{user.user_id}")
  end

  test "users can't join foreign channel", %{user: user} do
    {:error, %{reason: "unauthorized"}} =
      socket(CforumWeb.UserSocket, "user_id", %{current_user: user})
      |> subscribe_and_join(UsersChannel, "users:-1")

    {:error, %{reason: "unauthorized"}} =
      socket(CforumWeb.UserSocket, "user_id", %{})
      |> subscribe_and_join(UsersChannel, "users:#{user.user_id}")
  end

  test "lobby broadcasts are pushed to the client" do
    {:ok, _, socket} =
      socket(CforumWeb.UserSocket, "user_id", %{})
      |> subscribe_and_join(UsersChannel, "users:lobby")

    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end

  test "private broadcasts are pushed to the client", %{user: user} do
    {:ok, _, socket} =
      socket(CforumWeb.UserSocket, "user_id", %{current_user: user})
      |> subscribe_and_join(UsersChannel, "users:lobby")

    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
