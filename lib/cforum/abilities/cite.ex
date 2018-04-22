defmodule Cforum.Abilities.Cite do
  defmacro __using__(_opts) do
    quote do
      def may?(_conn, "cite", action, _) when action in [:index, :show, :new, :create], do: true
      def may?(conn, "cite", action, _) when action not in [:index, :show, :new, :create], do: admin?(conn)
      def may?(conn, "cite/vote", :vote, _), do: signed_in?(conn)
    end
  end
end
