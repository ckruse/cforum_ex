defmodule CforumWeb.Api.V1.Messages.VoteView do
  use CforumWeb, :view

  alias Cforum.Forums.Messages
  alias Cforum.Forums.Votes

  def render("vote.json", %{message: message, current_user: user}) do
    %{
      score: Messages.score(message),
      score_str: Messages.score_str(message),
      upvoted: Votes.upvoted?(message, user),
      downvoted: Votes.downvoted?(message, user)
    }
  end
end
