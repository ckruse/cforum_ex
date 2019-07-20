defmodule CforumWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", Cforum.RoomChannel
  channel "users:*", CforumWeb.UsersChannel
  channel "forum:*", CforumWeb.ForumChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket) do
    # max_age: 2592000 is equivalent to 30 days in seconds
    case Phoenix.Token.verify(socket, "user socket", token, max_age: 2_592_000) do
      {:ok, user_id} ->
        {:ok, assign(socket, :current_user, Cforum.Accounts.Users.get_user(user_id))}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, socket) do
    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     CforumWeb.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(%{assigns: %{current_user: user}}) when not is_nil(user), do: "users:#{user.user_id}"
  def id(_socket), do: nil
end
