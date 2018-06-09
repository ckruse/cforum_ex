defmodule Cforum.Abilities.Messages.MarkRead do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "messages/mark_read", _, _), do: signed_in?(conn)
    end
  end
end
