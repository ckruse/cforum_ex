defmodule CforumWeb.BadgeController do
  use CforumWeb, :controller

  alias Cforum.Badges

  alias CforumWeb.Paginator

  def index(conn, params) do
    count = Badges.count_badges()
    paging = Paginator.paginate(count, page: params["p"])
    badges = Badges.list_badges(limit: paging.params)
    render(conn, "index.html", badges: badges, page: paging)
  end

  def show(conn, %{"id" => id}) do
    badge = Badges.get_badge_by!([slug: id], with: [badges_users: [:user]])
    render(conn, "show.html", badge: badge)
  end

  def allowed?(_conn, _, _), do: true
end
