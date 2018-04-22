defmodule Cforum.UserFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.User

      def user_factory do
        %Cforum.Accounts.User{
          username: sequence("user-"),
          email: sequence(:email, &"user-#{&1}@example.org"),
          confirmed_at: Timex.now(),
          admin: false,
          active: true,
          activity: 0,
          encrypted_password: "",
          score: 0,
          badges: []
        }
      end

      def as_admin(user) do
        %{user | admin: true}
      end

      def with_password(user, pass) do
        %{user | encrypted_password: Comeonin.Bcrypt.hashpwsalt(pass)}
      end
    end

    # quote
  end

  # defmacro
end

# defmodule
