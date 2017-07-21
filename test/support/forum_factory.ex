defmodule Cforum.ForumFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Forums.Forum

      def forum_factory do
        %Forum{name: sequence("Forum "),
               short_name: sequence("Forum "),
               slug: sequence("forum-"),
               description: Faker.Lorem.sentence(%Range{first: 1, last: 3}),
               standard_permission: "private",
               position: 0}
      end

      def public_forum(forum) do
        %{forum | standard_permission: "write"}
      end

    end # quote
  end # defmacro
end # defmodule
