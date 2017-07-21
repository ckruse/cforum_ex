defmodule Cforum.ScoreFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.Score

      def score_factory do
        %Cforum.Accounts.Score{value: 10,
                               user: build(:user)}
      end

      def with_negative_score(score), do: %{score | value: -10}
      def with_message(score), do: %{score | message: build(:message)}
      def with_vote(score), do: %{score | vote: build(:vote)}
    end # quote
  end # defmacro
end # defmodule
