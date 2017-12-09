defmodule Cforum.ThreadFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Forums.Thread

      def thread_factory do
        %Thread{
          slug: sequence("/1999/mar/1/lulu"),
          forum: build(:forum),
          latest_message: Timex.now()
        }
      end
    end
  end
end
