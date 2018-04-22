defmodule Cforum.Abilities.Users.Session do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "users/session", :delete, _), do: signed_in?(conn)
      def may?(conn, "users/session", action, _) when action in [:new, :create], do: !signed_in?(conn)
    end
  end
end
