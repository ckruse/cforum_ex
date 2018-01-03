defmodule Cforum.VoteFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Forums.Vote

      def vote_factory do
        %Vote{vtype: Vote.upvote(), user: build(:user), message: build(:message), score: build(:score)}
      end
    end
  end
end
