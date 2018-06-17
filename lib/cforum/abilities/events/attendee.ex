defmodule Cforum.Abilities.Events.Attendee do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Events

      def may?(conn, "events/attendee", action, _) when action in [:new, :create] do
        base = present?(conn.assigns[:event]) && Events.open?(conn.assigns.event)

        if signed_in?(conn) do
          base &&
            Enum.find_value(conn.assigns.event.attendees, &(&1.user_id == conn.assigns.current_user.user_id)) == nil
        else
          base
        end
      end

      def may?(conn, "events/attendee", _, attendee) do
        attendee = attendee || conn.assigns[:attendee]

        admin?(conn) ||
          (signed_in?(conn) && present?(attendee) && attendee.user_id == conn.assigns[:current_user].user_id)
      end
    end
  end
end
