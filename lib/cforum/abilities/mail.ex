defmodule Cforum.Abilities.Mail do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.PrivMessages

      def may?(conn, "mail", :index, _), do: signed_in?(conn)

      def may?(conn, "mail", :show, resource) do
        resource = resource || PrivMessages.get_priv_message_thread!(conn.assigns[:current_user], conn.params["id"])
        signed_in?(conn) && conn.assigns[:current_user].user_id == List.first(resource).owner_id
      end

      def may?(conn, "mail", action, resource) when action in [:new, :create] do
        if conn.params["parent_id"] || resource do
          resource = resource || PrivMessages.get_priv_message!(conn.assigns[:current_user], conn.params["parent_id"])
          signed_in?(conn) && conn.assigns[:current_user].user_id == resource.owner_id
        else
          signed_in?(conn)
        end
      end

      def may?(conn, "mail", _, resource) do
        resource = resource || PrivMessages.get_priv_message!(conn.assigns[:current_user], conn.params["id"])
        signed_in?(conn) && conn.assigns[:current_user].user_id == resource.owner_id
      end
    end
  end
end
