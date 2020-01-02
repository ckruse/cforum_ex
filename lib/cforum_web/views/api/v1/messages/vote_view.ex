defmodule CforumWeb.Api.V1.Messages.VoteView do
  use CforumWeb, :view

  alias Cforum.Messages.MessageHelpers
  alias Cforum.Votes

  def render("vote.json", %{message: message, current_user: user}) do
    %{
      score: MessageHelpers.score(message),
      score_str: MessageHelpers.score_str(message),
      upvoted: Votes.upvoted?(message, user),
      downvoted: Votes.downvoted?(message, user)
    }
  end
end
