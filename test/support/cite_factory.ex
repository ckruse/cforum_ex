defmodule Cforum.CiteFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Cites.Cite
      alias Cforum.Cites.Vote

      def cite_factory do
        %Cite{
          archived: false,
          author: sequence("Author "),
          cite: Faker.Lorem.sentence(%Range{first: 1, last: 10}),
          cite_date: Timex.now(),
          creator: sequence("Creator "),
          url: sequence("https://example.com/cites/")
        }
      end

      def archived_cite(cite) do
        %Cite{cite | archived: true}
      end

      def cite_vote_factory do
        %Vote{
          vote_type: Vote.upvote(),
          user: build(:user),
          cite: build(:cite)
        }
      end
    end
  end
end
