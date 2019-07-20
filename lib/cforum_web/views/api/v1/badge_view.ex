defmodule CforumWeb.Api.V1.BadgeView do
  use CforumWeb, :view

  alias CforumWeb.Api.V1.BadgeView

  def render("index.json", %{badges: badges}) do
    render_many(badges, BadgeView, "badge.json")
  end

  def render("badge.json", %{badge: badge}) do
    %{
      badge_id: badge.badge_id,
      score_needed: badge.score_needed,
      name: badge.name,
      description: badge.description,
      slug: badge.slug,
      badge_medal_type: badge.badge_medal_type,
      badge_type: badge.badge_type,
      order: badge.order
    }
  end
end
