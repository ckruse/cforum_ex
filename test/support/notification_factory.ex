defmodule Cforum.NotificationFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.Notification

      def notification_factory do
        %Cforum.Accounts.Notification{
          is_read: false,
          subject: Faker.Lorem.sentence(%Range{first: 1, last: 10}),
          path: "/foo/bar",
          oid: 0,
          otype: "none",
          recipient: build(:user)
        }
      end
    end

    # quote
  end

  # defmacro
end

# defmodule
