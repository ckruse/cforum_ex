alias Cforum.Users.User

defimpl Jason.Encoder, for: User do
  def encode(%User{badges_users: %Ecto.Association.NotLoaded{}} = user, options),
    do: encode(%User{user | badges_users: []}, options)

  def encode(user, options) do
    Jason.Encode.map(
      %{
        user_id: user.user_id,
        username: user.username,
        active: user.active,
        score: user.score,
        activity: user.activity,
        created_at: user.created_at,
        admin: user.admin,
        avatar: %{
          thumb: Cforum.Users.User.avatar_path(user, :thumb),
          medium: Cforum.Users.User.avatar_path(user, :medium),
          original: Cforum.Users.User.avatar_path(user, :original)
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
