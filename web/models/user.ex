defmodule Cforum.User do
  use Cforum.Web, :model

  @primary_key {:user_id, :integer, []}
  @derive {Phoenix.Param, key: :user_id}

  schema "users" do
    field :username, :string
    field :email, :string
    field :unconfirmed_email, :string
    field :admin, :boolean, default: false
    field :active, :boolean, default: false
    field :encrypted_password, :string
    field :remember_created_at, :utc_datetime
    field :reset_password_token, :string
    field :confirmation_token, :string
    field :confirmed_at, :utc_datetime
    field :confirmation_sent_at, :utc_datetime
    field :last_sign_in_at, :utc_datetime
    field :current_sign_in_at, :utc_datetime
    field :avatar_file_name, :string
    field :avatar_content_type, :string
    field :avatar_updated_at, :utc_datetime

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_one :settings, Cforum.Setting

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
  end

  def by_username_or_email(query, login) do
    from user in query,
      where: user.active == true and (user.email == ^login or user.username == ^login)
  end
end
