defmodule CforumWeb.Api.V1.UserView do
  use CforumWeb, :view

  def render("index.json", %{users: users}), do: users
  def render("show.json", %{user: user}), do: user

  def render("show_self.json", %{user: user}) do
    %{
      user_id: user.user_id,
      username: user.username,
      active: user.active,
      score: user.score,
      activity: user.activity,
      created_at: user.created_at,
      avatar: %{
        thumb: Cforum.Users.User.avatar_path(user, :thumb),
        medium: Cforum.Users.User.avatar_path(user, :medium),
        original: Cforum.Users.User.avatar_path(user, :original)
      },
      badges:
        Enum.map(
          user.badges_users,
          &%{
            name: &1.badge.name,
            slug: &1.badge.slug,
            badge_medal_type: &1.badge.badge_medal_type,
            badge_type: &1.badge.badge_type,
            active: &1.active
          }
        )
    }
  end

  def render("activity.json", %{activity: activity}) do
    Enum.map(activity, fn {month, msgs} -> %{month: NaiveDateTime.to_date(month), messages: msgs} end)
  end
end
