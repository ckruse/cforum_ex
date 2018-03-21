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
        }
      },
      options
    )
  end
end
