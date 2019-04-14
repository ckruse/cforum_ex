defmodule CforumWeb.ForumChannel do
  use CforumWeb, :channel

  alias Cforum.Forums
  alias Cforum.Abilities

  def join("forum:" <> id, _payload, socket) do
    if authorized?(id, socket.assigns[:current_user]),
      do: {:ok, socket},
      else: {:error, %{reason: "unauthorized"}}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  # # It is also common to receive messages from the client and
  # # broadcast to everyone in the current topic (forum:lobby).
  # def handle_in("shout", payload, socket) do
  #   broadcast(socket, "shout", payload)
  #   {:noreply, socket}
  # end

  # Add authorization logic here as required.
  defp authorized?(forum_id, user) do
    forum = Forums.get_forum!(forum_id)
    Abilities.access_forum?(user, forum, :read)
  end
end
