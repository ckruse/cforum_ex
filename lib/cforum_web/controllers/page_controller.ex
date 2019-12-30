defmodule CforumWeb.PageController do
  use CforumWeb, :controller

  def help(conn, _params) do
    moderators = Cforum.Users.list_moderators()
    badge_groups = Cforum.Badges.list_badge_groups()
    cites_stats = Cforum.Cites.cites_stats(12, :months)

    render(conn, "help.html", moderators: moderators, badge_groups: badge_groups, cites_stats: cites_stats)
  end

  def allowed?(_, _, _), do: true
end
