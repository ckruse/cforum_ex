defmodule CforumWeb.Api.V1.BadgeController do
  use CforumWeb, :controller

  alias Cforum.Badges

  def index(conn, _params) do
    badges = Badges.list_badges(preload: [])
    render(conn, "index.json", badges: badges)
  end

  def allowed?(_conn, _, _), do: true
end
