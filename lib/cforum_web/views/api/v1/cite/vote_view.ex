defmodule CforumWeb.Api.V1.Cite.VoteView do
  use CforumWeb, :view

  alias Cforum.Cites

  def render("vote.json", %{cite: cite, current_user: user}) do
    %{
      score: Cites.no_votes(cite),
      score_str: Cites.score_str(cite),
      upvoted: Cites.upvoted?(cite, user),
      downvoted: Cites.downvoted?(cite, user)
    }
  end
end
