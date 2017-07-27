defmodule Cforum.Accounts.Setting do
  use CforumWeb, :model

  @primary_key {:setting_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :setting_id}

  schema "settings" do
    field :options, :map
    belongs_to :forum, Cforum.Forums.Forum, references: :forum_id
    belongs_to :user, Cforum.Accounts.User, references: :user_id
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :unconfirmed_email, :admin, :active, :encrypted_password, :remember_created_at, :reset_password_token, :confirmation_token, :confirmed_at, :confirmation_sent_at, :authentication_token, :last_sign_in_at, :current_sign_in_at, :avatar_file_name, :avatar_content_type, :avatar_updated_at])
    |> validate_required([:username, :email, :unconfirmed_email, :admin, :active, :encrypted_password, :remember_created_at, :reset_password_token, :confirmation_token, :confirmed_at, :confirmation_sent_at, :authentication_token, :last_sign_in_at, :current_sign_in_at, :avatar_file_name, :avatar_content_type, :avatar_updated_at])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> unique_constraint(:unconfirmed_email)
    |> unique_constraint(:reset_password_token)
    |> unique_constraint(:confirmation_token)
    |> unique_constraint(:authentication_token)
  end

  def conf(setting, nam) do
    setting.options[nam] || Cforum.ConfigManager.defaults[nam]
  end

  def global(query) do
    from setting in query,
      where: is_nil(setting.forum_id) and is_nil(setting.user_id)
  end


  def load_all(query, nil, nil) do
    global(query)
  end
  def load_all(query, forum, nil) do
    from setting in query,
      where: (is_nil(setting.forum_id) and is_nil(setting.user_id)) or
             (is_nil(setting.user_id) and setting.forum_id == ^forum.forum_id)
  end
  def load_all(query, nil, user) do
    from setting in query,
      where: (is_nil(setting.forum_id) and is_nil(setting.user_id)) or
             (is_nil(setting.forum_id) and setting.user_id == ^user.user_id)
  end
  def load_all(query, forum, user) do
    from setting in query,
      where: (is_nil(setting.forum_id) and is_nil(setting.user_id)) or
             (is_nil(setting.forum_id) and setting.user_id == ^user.user_id) or
             (is_nil(setting.user_id) and setting.forum_id == ^forum.forum_id)
  end
end
