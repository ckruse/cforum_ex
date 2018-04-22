defmodule Cforum.Abilities.V1.Api do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "api/v1/" <> _, _, _), do: true
    end
  end
end
