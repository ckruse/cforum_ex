defmodule Cforum.Abilities.Message do
  defmacro __using__(_opts) do
    quote do
      # TODO implement proper rights
      def may?(conn, "message", _, _), do: access_forum?(conn)
    end
  end
end
