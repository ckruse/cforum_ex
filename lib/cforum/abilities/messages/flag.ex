defmodule Cforum.Abilities.Messages.Flag do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "messages/flag", _, _), do: true
    end
  end
end
