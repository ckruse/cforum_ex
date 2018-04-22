defmodule Cforum.Abilities.Users.User do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "users/user", action, _) when action in [:index, :show, :show_messages, :show_scores], do: true

      def may?(conn, "users/user", :update, resource) do
        cuser = conn.assigns[:current_user]

        uid =
          if resource != nil, do: resource.user_id, else: String.to_integer(conn.params["user_id"] || conn.params["id"])

        cuser != nil && (admin?(cuser) || uid == cuser.user_id)
      end

      def may?(conn, "users/user", action, resource) when action in [:edit, :delete, :confirm_delete],
        do: may?(conn, "users/user", :update, resource)

      def may?(conn, "users/user", :show_votes, resource) do
        cuser = conn.assigns[:current_user]
        uid = if resource != nil, do: resource.user_id, else: String.to_integer(conn.params["id"])
        cuser != nil && uid == cuser.user_id
      end
    end
  end
end
