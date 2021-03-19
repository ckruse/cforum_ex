defmodule Cforum.Jobs.VoteBadgeDistributorJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  alias Cforum.Votes
  alias Cforum.Votes.Vote
  alias Cforum.Messages
  alias Cforum.Messages.MessageHelpers
  alias Cforum.Users
  alias Cforum.Badges
  alias Cforum.Badges.{Badge, BadgeUser}
  alias Cforum.Repo
  alias Cforum.Helpers

  import Ecto.Query, warn: false

  def enqueue(vote) do
    %{"vote_id" => vote.vote_id}
    |> Cforum.Jobs.VoteBadgeDistributorJob.new()
    |> Oban.insert!()
  end

  def perform(%Oban.Job{args: %{"vote_id" => id}}) do
    vote = Votes.get_vote!(id)
    user = Users.get_user!(vote.user_id)
    message = Messages.get_message!(vote.message_id, view_all: true)

    grant_voter_badges(vote, user)

    if Helpers.present?(message.user_id) do
      owner = Users.get_user!(message.user_id)
      grant_bevoted_badges(owner, message)
      grant_controverse_badge(owner, message)
      grant_badges_by_score(owner)
    end

    :ok
  end

  defp grant_controverse_badge(owner, message) do
    controverse = Badges.get_badge_by(slug: "controverse")

    if message.upvotes >= 5 && message.downvotes >= 5 && !Users.badge?(owner, controverse),
      do: Badges.grant_badge(controverse, owner)
  end

  @voter_badge_limits [100, 250, 500, 1000, 2500, 5000, 10_000]
  defp grant_voter_badges_by_limits(user, badge) do
    all_user_votes =
      from(vote in Vote, where: vote.user_id == ^user.user_id, select: count())
      |> Repo.one!()

    voter_badges =
      from(badge_user in BadgeUser,
        where: badge_user.user_id == ^user.user_id and badge_user.badge_id == ^badge.badge_id,
        select: count()
      )
      |> Repo.one!()

    user_should_have_badges =
      Enum.reduce(@voter_badge_limits, 0, fn
        limit, acc when all_user_votes >= limit -> acc + 1
        _, acc -> acc
      end)

    if user_should_have_badges - voter_badges > 0 do
      for i <- 0..(user_should_have_badges - voter_badges), i > 0 do
        Badges.grant_badge(badge, user)
      end
    end
  end

  defp grant_voter_badges(vote, user) do
    enthusiast = Badges.get_badge_by(slug: "enthusiast")
    critic = Badges.get_badge_by(slug: "critic")

    if Helpers.present?(enthusiast) && vote.vtype == Vote.upvote() && !Users.badge?(user, enthusiast),
      do: Badges.grant_badge(enthusiast, user)

    if Helpers.present?(critic) && vote.vtype == Vote.downvote() && !Users.badge?(user, critic),
      do: Badges.grant_badge(critic, user)

    badge = Badges.get_badge_by(slug: "voter")

    if Helpers.present?(badge),
      do: grant_voter_badges_by_limits(user, badge)
  end

  @bevoted_badges [
    %{votes: 1, name: "donee"},
    %{votes: 5, name: "nice_answer"},
    %{votes: 10, name: "good_answer"},
    %{votes: 15, name: "great_answer"},
    %{votes: 20, name: "superb_answer"}
  ]
  defp grant_bevoted_badges(user, message) do
    votes = MessageHelpers.score(message)

    Enum.each(@bevoted_badges, fn badge_type ->
      badge = Badges.get_badge_by(slug: badge_type[:name])

      if Helpers.present?(badge) && votes >= badge_type[:votes] && !Users.badge?(user, badge, false),
        do: Badges.grant_badge(badge, user)
    end)
  end

  defp grant_badges_by_score(user) do
    badges =
      from(badge in Badge, where: badge.score_needed <= ^user.score)
      |> Repo.all()

    Enum.each(badges, fn b ->
      if !Users.badge?(user, b),
        do: Badges.grant_badge(b, user)
    end)
  end
end
