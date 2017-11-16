defmodule Cforum.BadgeFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.Badge

      def badge_factory do
        %Cforum.Accounts.Badge{
          name: sequence("Badge "),
          slug: sequence("slug-"),
          badge_medal_type: "bronze",
          badge_type: "custom",
          order: 0
        }
      end
    end

    # quote
  end

  # defmacro
end

# defmodule
