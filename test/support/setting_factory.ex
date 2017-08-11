defmodule Cforum.SettingFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.Setting

      def setting_factory do
        %Setting{options: %{}}
      end

      def setting_with_user(setting) do
        %Setting{setting | user: build(:user)}
      end

      def setting_with_forum(setting) do
        %Setting{setting | forum: build(:forum)}
      end
    end
  end
end
