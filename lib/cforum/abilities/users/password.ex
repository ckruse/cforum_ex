defmodule Cforum.Abilities.Users.Password do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "users/password", action, resource) when action in [:new, :create, :edit_reset, :update_reset],
        do: !signed_in?(conn)

      def may?(conn, "users/password", action, resource) when action in [:edit, :update],
        do: may?(conn, "users/user", :update, resource)
    end
  end
end
