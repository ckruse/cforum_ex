defmodule Cforum.CloseVoteFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Forums.CloseVote

      def close_vote_factory do
        %CloseVote{
          reason: "spam",
          vote_type: false,
          finished: false,
          message: build(:message)
        }
      end
    end
  end
end
