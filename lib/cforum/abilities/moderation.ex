defmodule Cforum.Abilities.Moderation do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "moderation", :index, _), do: conn.assigns.is_moderator
      def may?(conn, "moderation", :index_open, _), do: conn.assigns.is_moderator

      def may?(conn, "moderation", action, entry) when action in [:edit, :update] do
        entry = entry || conn.assigns[:entry]
        access_forum?(conn.assigns.current_user, entry.message.forum, :moderate) && entry.cleared == false
      end

      def may?(conn, "moderation", :show, entry) do
        entry = entry || conn.assigns[:entry]
        access_forum?(conn.assigns.current_user, entry.message.forum, :moderate)
      end
    end
  end
end
