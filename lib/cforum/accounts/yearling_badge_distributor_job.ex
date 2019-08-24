defmodule Cforum.Accounts.YearlingBadgeDistributorJob do
  use Appsignal.Instrumentation.Decorators

  alias Cforum.Repo
  alias Cforum.Helpers
  alias Cforum.Accounts.Users
  alias Cforum.Accounts.{Badge, Badges}

  @decorate transaction(:maintenance)
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
          if Helpers.blank?(last_yearling),
            do: Timex.diff(Timex.now(), user.created_at, :years),
            else: Timex.diff(Timex.now(), last_yearling.created_at, :years)

        for i <- 0..difference, i > 0, do: Badges.grant_badge(yearling_badge, user)
      end
    end
  end
end
