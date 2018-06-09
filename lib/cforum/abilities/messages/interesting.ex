defmodule Cforum.Abilities.Messages.Interesting do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "messages/interesting", :interesting, message) do
        message = message || conn.assigns.message
        signed_in?(conn) && message.attribs[:is_interesting] != true
      end

      def may?(conn, "messages/interesting", :boring, message) do
        message = message || conn.assigns.message
        signed_in?(conn) && message.attribs[:is_interesting] == true
      end

      def may?(conn, "messages/interesting", _, _), do: signed_in?(conn)
    end
  end
end
