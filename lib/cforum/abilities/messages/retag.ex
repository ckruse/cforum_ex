defmodule Cforum.Abilities.Messages.Retag do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "messages/retag", _, _), do: true
    end
  end
end
