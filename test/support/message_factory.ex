defmodule Cforum.MessageFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Forums.Message

      def message_factory do
        %Message{
          author: Faker.Name.name(),
          subject: Faker.Lorem.sentence(%Range{first: 1, last: 10}),
          content: Faker.Lorem.paragraph(%Range{first: 1, last: 2})
        }
      end
    end
  end
end
