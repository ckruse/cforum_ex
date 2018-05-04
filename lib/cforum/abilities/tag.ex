defmodule Cforum.Abilities.Tag do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "tag", action, _) when action in [:index, :show], do: access_forum?(conn)

      def may?(conn, "tag", action, _) when action in [:new, :create] do
        access_forum?(conn) && (admin?(conn) || badge?(conn, "create_tag") || badge?(conn, "moderator_tools"))
      end

      def may?(conn, "tag", action, _) when action in [:edit, :update, :edit_merge, :merge] do
        access_forum?(conn) && (admin?(conn) || badge?(conn, "moderator_tools"))
      end

      def may?(conn, "tag", :delete, _) do
        access_forum?(conn) && (admin?(conn) || badge?(conn, "moderator_tools"))
      end
    end
  end
end
