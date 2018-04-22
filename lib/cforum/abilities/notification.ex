defmodule Cforum.Abilities.Notification do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "notification", :index, _), do: signed_in?(conn)

      def may?(conn, "notification", _, ressource) do
        ressource = load_notification_ressource(conn, ressource)
        signed_in?(conn) && conn.assigns[:current_user].user_id == ressource.recipient_id
      end

      defp load_notification_ressource(conn, nil),
        do: Cforum.Accounts.Notifications.get_notification!(conn.params["notification_id"] || conn.params["id"])

      defp load_notification_ressource(_, resource), do: resource
    end
  end
end
