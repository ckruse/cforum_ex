defmodule Cforum.Abilities.Events.Attendee do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "events/attendee", action, _) when action in [:new, :create],
        do: present?(conn.assigns[:event]) && conn.assigns[:event].visible == true

      def may?(conn, "events/attendee", _, resource) do
        admin?(conn) ||
          (signed_in?(conn) && present?(conn.assigns[:attendee]) &&
             conn.assigns[:attendee].user_id == conn.assigns[:current_user].user_id)
      end
    end
  end
end
