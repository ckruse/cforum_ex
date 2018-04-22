defmodule Cforum.Abilities.Admin.Forum do
  defmacro __using__(_opts) do
    quote do
      def may?(conn, "admin/forum", _, _), do: admin?(conn)
    end
  end
end
