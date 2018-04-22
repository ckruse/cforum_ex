defmodule Cforum.Abilities.Users.Registration do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "users/registration", _, _), do: !signed_in?(conn)
    end
  end
end
