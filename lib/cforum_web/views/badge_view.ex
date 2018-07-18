defmodule CforumWeb.BadgeView do
  use CforumWeb, :view

  alias Cforum.Accounts.Badges

  def page_title(:index, _), do: gettext("badges")
  def page_title(:show, assigns), do: gettext("badge %{name}", name: assigns.badge.name)

  def page_heading(:show, assigns) do
    [
      {:safe, "<img src=\""},
      badge_image(assigns.conn, assigns.badge),
      {:safe, "\">"},
      " ",
      gettext("badge %{name}", name: assigns.badge.name)
    ]
  end

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "badges-index"
  def body_id(:show, _), do: "badges-show"

  def body_classes(:index, _), do: "badges index"
  def body_classes(:show, _), do: "badges show"

  def badge_image(conn, badge), do: static_path(conn, "/images/#{badge.badge_medal_type}.png")
end
