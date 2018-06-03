defmodule Cforum.Abilities.Event do
  defmacro __using__(_opts) do
    quote do
      def may?(_conn, "event", :index, _), do: true
      def may?(_conn, "event", :show, _), do: true
    end
  end
end
