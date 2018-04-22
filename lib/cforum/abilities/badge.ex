defmodule Cforum.Abilities.Badge do
  defmacro __using__(_opts) do
    quote do
      def may?(_conn, "badge", action, _), do: true
    end
  end
end
