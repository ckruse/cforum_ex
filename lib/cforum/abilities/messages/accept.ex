defmodule Cforum.Abilities.Messages.Accept do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Forums.Message

      def may?(conn, "messages/accept", :accept, msg) do
        msg = msg || conn.assigns.message
        accept?(conn, msg) && !Message.accepted?(msg)
      end

      def may?(conn, "messages/accept", :unaccept, msg) do
        msg = msg || conn.assigns.message
        accept?(conn, msg) && Message.accepted?(msg)
      end
    end
  end
end
