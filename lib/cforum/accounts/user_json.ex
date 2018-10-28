defimpl Poison.Encoder, for: Cforum.Accounts.User do
  def encode(user, options) do
    Poison.Encoder.Map.encode(
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
            user.badges_users,
            &%{
              badge_user_id: &1.badge_user_id,
              badge_id: &1.badge_id,
              name: &1.badge.name,
              slug: &1.badge.slug,
              badge_medal_type: &1.badge.badge_medal_type,
              badge_type: &1.badge.badge_type,
              active: &1.active
            }
          )
      },
      options
    )
  end
end
