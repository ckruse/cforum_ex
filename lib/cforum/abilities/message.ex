defmodule Cforum.Abilities.Message do
  defmacro __using__(_opts) do
    quote do
      # TODO implement proper rights
      def may?(conn, "message", _, _), do: access_forum?(conn)

      def may?(conn, "messages/mark_read", _, _), do: signed_in?(conn)

      def may?(conn, "messages/subscription", :subscribe, message) do
        message = message || conn.assigns.message
        signed_in?(conn) && message.attribs[:is_subscribed] != true
      end

      def may?(conn, "messages/subscription", :unsubscribe, message) do
        message = message || conn.assigns.message
        signed_in?(conn) && message.attribs[:is_subscribed] == true
      end

      def may?(conn, "messages/subscription", _, _), do: signed_in?(conn)

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
