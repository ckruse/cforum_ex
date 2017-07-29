defmodule Cforum.BadgeUserFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.BadgeUser

      def badge_user_factory do
        %BadgeUser{badge: build(:badge), user: build(:user)}
      end
    end
  end
end
