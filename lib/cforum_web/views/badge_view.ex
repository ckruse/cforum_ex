defmodule CforumWeb.BadgeView do
  use CforumWeb, :view

  alias Cforum.Accounts.Badges

  alias CforumWeb.Paginator

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def page_title(:index, _), do: gettext("badges")
  def page_title(:show, assigns), do: gettext("badge %{name}", name: assigns.badge.name)

  def page_heading(:show, assigns) do
    [
      badge_image(assigns.conn, assigns.badge),
      " ",
      gettext("badge %{name}", name: assigns.badge.name)
    ]
  end

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "badges-index"
  def body_id(:show, _), do: "badges-show"

  def body_classes(:index, _), do: "badges index"
  def body_classes(:show, _), do: "badges show"

  def badge_image(conn, badge, classes \\ []) do
    [
      {:safe, "<svg class=\"cf-badge-image "},
      Enum.join(classes, " "),
      {:safe,
       "\" width=\"109\" height=\"109\" viewBox=\"0 0 109 109\" xmlns=\"http://www.w3.org/2000/svg\"><use xlink:href=\""},
      Routes.static_path(conn, "/images/badges.svg"),
      "#",
      badge.badge_medal_type,
      {:safe, "\"></use></svg>"}
    ]
  end
end
