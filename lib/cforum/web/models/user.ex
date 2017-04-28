defmodule Cforum.User do
  use Cforum.Web, :model
  use Arc.Ecto.Schema

  import Cforum.Web.Gettext
  alias Phoenix.Token

  @primary_key {:user_id, :integer, []}
  @derive {Phoenix.Param, key: :user_id}

  schema "users" do
    field :username, :string
    field :email, :string
    field :unconfirmed_email, :string
    field :admin, :boolean, default: false
    field :active, :boolean, default: false
    field :encrypted_password, :string
    field :remember_created_at, Timex.Ecto.DateTime
    field :reset_password_token, :string
    field :confirmation_token, :string
    field :confirmed_at, Timex.Ecto.DateTime
    field :confirmation_sent_at, Timex.Ecto.DateTime
    field :last_sign_in_at, Timex.Ecto.DateTime
    field :current_sign_in_at, Timex.Ecto.DateTime
    field :avatar_file_name, Cforum.Web.Avatar.Type
    field :avatar_content_type, :string
    field :avatar_updated_at, Timex.Ecto.DateTime
    field :score, :integer
    field :activity, :integer

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_one :settings, Cforum.Setting, foreign_key: :user_id
    has_many :badges_users, Cforum.BadgeUser, foreign_key: :user_id
    has_many :badges, through: [:badges_users, :badge]

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :unconfirmed_email, :admin, :active, :encrypted_password, :remember_created_at, :reset_password_token, :confirmation_token, :confirmed_at, :confirmation_sent_at, :last_sign_in_at, :current_sign_in_at, :avatar_file_name, :avatar_content_type, :avatar_updated_at])
    |> validate_required([:username, :email, :admin, :active])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> unique_constraint(:unconfirmed_email)
    |> unique_constraint(:reset_password_token)
    |> unique_constraint(:confirmation_token)
  end

  def register_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password, :password_confirmation])
    |> validate_required([:username, :email, :password, :password_confirmation])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> confirm_password()
    |> put_password_hash()
    |> put_confirmation_token()
  end

  defp confirm_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass, password_confirmation: confirmed_pass}} when pass == confirmed_pass ->
        changeset
      _ ->
        add_error(changeset, :password, gettext("password and password confirmation don't match"))
    end
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  defp put_confirmation_token(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{username: username}} ->
        put_change(changeset, :confirmation_token, generate_confirmation_token(username))
      _ ->
        changeset
    end
  end

  defp generate_confirmation_token(nil), do: nil
  defp generate_confirmation_token(username) do
    Token.sign(Cforum.Endpoint, "user", username)
  end


  def by_username_or_email(query, login) do
    from user in query,
      where: user.active == true and (user.email == ^login or user.username == ^login)
  end

  def avatar_path(user, version) do
    Cforum.Web.Avatar.url({user.avatar_file_name, user}, version)
    |> String.replace_leading("/priv", "")
  end

  def ordered(query, ordering \\ [asc: :username]) do
    from query,
      order_by: ^ordering
  end

  def conf(user, name) do
    vals = case user.settings do
             nil ->
               {}
             set ->
               set.options || {}
           end

    vals[name] || Cforum.ConfigManager.defaults[name]
  end

  def unique_badges(user) do
    Enum.reduce(user.badges_users, %{}, fn(b, acc) ->
      val = case acc[b.badge_id] do
              nil ->
                %{badge: b.badge, created_at: b.created_at, times: 1}
              entry ->
                %{entry | times: entry.times + 1}
            end
      Map.put(acc, b.badge_id, val)
    end)
    |> Map.values
    |> Enum.sort(&(&1[:times] >= &2[:times]))
  end
end
