defmodule Cforum.Users.User do
  use CforumWeb, :model
  use Waffle.Ecto.Schema

  alias Cforum.Helpers
  alias Phoenix.Token

  alias Cforum.Users.User

  @primary_key {:user_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :user_id}

  schema "users" do
    field(:username, :string)
    field(:email, :string)
    field(:unconfirmed_email, :string)
    field(:admin, :boolean, default: false)
    field(:active, :boolean, default: false)
    field(:encrypted_password, :string)
    field(:remember_created_at, :utc_datetime)
    field(:reset_password_token, :string)
    field(:reset_password_sent_at, :utc_datetime)
    field(:confirmation_token, :string)
    field(:confirmation_captcha, :string)
    field(:confirmed_at, :utc_datetime)
    field(:confirmation_sent_at, :utc_datetime)
    field(:last_visit, :utc_datetime)
    field(:avatar_file_name, CforumWeb.Avatar.Type)
    field(:avatar_content_type, :string)
    field(:avatar_updated_at, :utc_datetime)
    field(:score, :integer)
    field(:activity, :integer)
    field(:inactivity_notification_sent_at, :naive_datetime)

    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:login, :string, virtual: true)

    has_one(:settings, Cforum.Settings.Setting, foreign_key: :user_id)
    has_many(:badges_users, Cforum.Badges.BadgeUser, foreign_key: :user_id, on_replace: :delete)
    has_many(:badges, through: [:badges_users, :badge])

    has_many(:cites, Cforum.Cites.Cite, foreign_key: :user_id)

    many_to_many(
      :groups,
      Cforum.Groups.Group,
      join_through: "groups_users",
      on_delete: :delete_all,
      unique: true,
      join_keys: [user_id: :user_id, group_id: :group_id]
    )

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(%User{} = struct, params \\ %{}) do
    struct
    |> cast(params, [
      :username,
      :email,
      :unconfirmed_email
    ])
    |> cast_assoc(:settings)
    |> cast_attachments(params, [:avatar_file_name])
    |> validate_required([:username, :email])
    |> unique_constraint(:username, name: :users_username_idx)
    |> unique_constraint(:email, name: :users_email_idx)
    |> unique_constraint(:unconfirmed_email)
  end

  def admin_changeset(%User{} = struct, params \\ %{}) do
    struct
    |> cast(Map.put_new(params, "badges_users", []), [
      :username,
      :email,
      :password,
      :password_confirmation,
      :active,
      :admin
    ])
    |> cast_assoc(:badges_users)
    |> validate_required([:username, :email])
    |> unique_constraint(:username, name: :users_username_idx)
    |> unique_constraint(:email, name: :users_email_idx)
    |> maybe_confirm_password()
    |> maybe_put_password()
  end

  def register_changeset(%User{} = struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password, :password_confirmation])
    |> validate_required([:username, :email, :password, :password_confirmation])
    |> unique_constraint(:username, name: :users_username_idx)
    |> unique_constraint(:email, name: :users_email_idx)
    |> unique_constraint(:confirmation_token, name: :users_confirmation_token_idx)
    |> confirm_password()
    |> put_password_hash()
    |> put_confirmation_token()
  end

  def confirmation_changeset(%User{} = struct, params \\ %{}) do
    struct
    |> cast(params, [:confirmed_at, :confirmation_token])
    |> validate_required([:confirmed_at])
  end

  def password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> confirm_password()
    |> put_password_hash()
  end

  def login_changeset(%User{} = user, params \\ %{}) do
    user
    |> cast(params, [:login, :password])
    |> validate_required([:login, :password])
  end

  def reset_password_token_changeset(%User{} = user, params \\ %{}) do
    user
    |> cast(params, [:reset_password_token, :reset_password_sent_at])
    |> validate_required([:reset_password_token, :reset_password_sent_at])
    |> unique_constraint(:reset_password_token, name: :users_reset_password_token_idx)
  end

  defp maybe_confirm_password(changeset) do
    if Helpers.blank?(get_field(changeset, :password)),
      do: changeset,
      else: confirm_password(changeset)
  end

  defp confirm_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass, password_confirmation: confirmed_pass}}
      when pass == confirmed_pass ->
        changeset

      _ ->
        add_error(changeset, :password, "password and password confirmation don't match")
    end
  end

  defp maybe_put_password(changeset) do
    if Helpers.blank?(get_field(changeset, :password)),
      do: changeset,
      else: put_password_hash(changeset)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        change(changeset, Bcrypt.add_hash(pass, hash_key: :encrypted_password))

      _ ->
        changeset
    end
  end

  defp put_confirmation_token(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{username: username}} ->
        changeset
        |> put_change(:confirmation_token, generate_confirmation_token(username))
        |> put_change(:confirmation_sent_at, DateTime.truncate(Timex.now(), :second))

      _ ->
        changeset
    end
  end

  defp generate_confirmation_token(nil), do: nil
  defp generate_confirmation_token(username), do: Token.sign(CforumWeb.Endpoint, "user", username)

  def avatar_path(user, version) do
    path = Application.get_env(:cforum, :avatar_dir)
    url = Application.get_env(:cforum, :avatar_url)

    {user.avatar_file_name, user}
    |> CforumWeb.Avatar.url(version)
    |> String.replace_leading(path, url)
  end
end
