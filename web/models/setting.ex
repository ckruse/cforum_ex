defmodule Cforum.Setting do
  use Cforum.Web, :model

  @primary_key {:setting_id, :integer, []}
  @derive {Phoenix.Param, key: :setting_id}

  schema "settings" do
    field :options, :map
    belongs_to :forum, Cforum.Forum
    belongs_to :user, Cforum.User
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
end
