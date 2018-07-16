defmodule Cforum.AttendeeFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Events.Attendee

      def attendee_factory do
        %Attendee{
          name: sequence("Attendee "),
          planned_arrival: Timex.now(),
          event: build(:event)
        }
      end
    end
  end
end
