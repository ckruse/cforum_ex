defmodule Cforum.Abilities.Messages.Subscription do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "messages/subscription", :subscribe, message) do
        message = message || conn.assigns.message
        signed_in?(conn) && message.attribs[:is_subscribed] != true
      end

      def may?(conn, "messages/subscription", :unsubscribe, message) do
        message = message || conn.assigns.message
        signed_in?(conn) && message.attribs[:is_subscribed] == true
      end

      def may?(conn, "messages/subscription", _, _), do: signed_in?(conn)
    end
  end
end
