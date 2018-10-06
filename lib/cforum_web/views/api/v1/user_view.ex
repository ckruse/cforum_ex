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
        thumb: Cforum.Accounts.User.avatar_path(user, :thumb),
        medium: Cforum.Accounts.User.avatar_path(user, :medium),
        original: Cforum.Accounts.User.avatar_path(user, :original)
      },
      badges:
        Enum.map(
          user.badges,
          &%{name: &1.name, slug: &1.slug, badge_medal_type: &1.badge_medal_type, badge_type: &1.badge_type}
        )
    }
  end
end
