defmodule Cforum.Abilities.Admin do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "admin/" <> _, _, _), do: admin?(conn)
    end
  end
end
