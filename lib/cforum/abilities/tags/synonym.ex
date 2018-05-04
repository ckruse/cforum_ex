defmodule Cforum.Abilities.Tags.Synonym do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.Badge

      def may?(conn, "tags/synonym", _, _) do
        access_forum?(conn) &&
          badge?(conn, Badge.create_tag_synonym() || badge?(conn, Badge.moderator_tools()) || admin?(conn))
      end
    end
  end
end
