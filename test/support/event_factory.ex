defmodule Cforum.EventFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Events.Event

      def event_factory do
        %Event{
          name: sequence("Event "),
          start_date: Timex.today(),
          end_date: Timex.today() |> Timex.shift(days: 2),
          location: sequence("Location "),
          description: Faker.Lorem.paragraph(%Range{first: 1, last: 2}),
          visible: false
        }
      end
    end

    # quote
  end

  # defmacro
end

# defmodule
