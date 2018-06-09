defmodule Cforum.Abilities.Messages.Vote do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Forums.Message

      def may?(conn, "messages/vote", :upvote, msg) do
        msg = msg || conn.assigns.message

        signed_in?(conn) && access_forum?(conn, :write) && (admin?(conn) || badge?(conn, "upvote")) &&
          !Message.closed?(msg)
      end

      def may?(conn, "messages/vote", :downvote, msg) do
        msg = msg || conn.assigns.message

        signed_in?(conn) && access_forum?(conn, :write) && (admin?(conn) || badge?(conn, "downvote")) &&
          !Message.closed?(msg) && conn.assigns.current_user.score > 0
      end
    end
  end
end
