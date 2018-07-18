defmodule CforumWeb.BadgeController do
  use CforumWeb, :controller

  alias Cforum.Accounts.Badges

  def index(conn, params) do
    count = Badges.count_badges()
    paging = paginate(count, page: params["p"])
    badges = Badges.list_badges(limit: paging.params)
    render(conn, "index.html", badges: badges, page: paging)
  end

  def show(conn, %{"id" => id}) do
    badge = Badges.get_badge!(id)
    render(conn, "show.html", badge: badge)
  end
end
