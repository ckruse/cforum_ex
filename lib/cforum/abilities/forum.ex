defmodule Cforum.Abilities.Forum do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "forum", :index, _), do: true
    end
  end
end
