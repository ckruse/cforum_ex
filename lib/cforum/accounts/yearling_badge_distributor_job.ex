defmodule Cforum.Accounts.YearlingBadgeDistributorJob do
  alias Cforum.Repo
  alias Cforum.Accounts.Users
  alias Cforum.Accounts.{Badge, Badges}

  import Cforum.Helpers, only: [blank?: 1]

  def perform do
    users =
      Users.all_users()
      |> Repo.preload([:badges_users])

    with %Badge{} = yearling_badge <- Badges.get_badge_by(slug: "yearling") do
      for user <- users do
        last_yearling =
          user.badges_users
          |> Enum.filter(&(&1.badge_id == yearling_badge.badge_id))
          |> Enum.max_by(&Timex.to_erl(&1.created_at), fn -> nil end)

        difference =
          if blank?(last_yearling),
            do: Timex.diff(Timex.now(), user.created_at, :years),
            else: Timex.diff(Timex.now(), last_yearling.created_at, :years)

        for i <- 0..difference, i > 0, do: Badges.grant_badge(yearling_badge, user)
      end
    end
  end
end
