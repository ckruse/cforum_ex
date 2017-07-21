defmodule Cforum.PrivMessageFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.PrivMessage

      def priv_message_factory do
        %Cforum.Accounts.PrivMessage{owner: build(:user),
                                     is_read: false,
                                     subject: sequence("Subject "),
                                     body: Faker.Lorem.paragraph(%Range{first: 1, last: 3}),
                                     sender_name: Faker.Name.name,
                                     recipient_name: Faker.Name.name}
      end
    end # quote
  end # defmacro
end # defmodule
