defmodule Cforum.GroupFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.Group

      def group_factory do
        %Group{name: sequence("Group ")}
      end
    end
  end
end
