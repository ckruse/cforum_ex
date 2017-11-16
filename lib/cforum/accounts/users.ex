defmodule Cforum.Accounts.Users do
  @moduledoc """
  The boundary for the Accounts.Users system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Accounts.User
  alias Cforum.Accounts.ForumGroupPermission
  alias Cforum.Accounts.Badge

  @doc """
  Returns the list of users.

  ## Parameters

  - query_params: an option list containing a `order` and a `limit` option,
    describing the sort order and the offset/limit

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(query_params \\ [order: nil, limit: nil]) do
    User
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
  end

  @doc """
  Returns the number of users

  ## Examples

      iex> count_users()
      0
  """
  def count_users do
    User
    |> select(count("*"))
    |> Repo.one()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    from(
      u in User,
      preload: [:settings, :badges, [badges_users: :badge]],
      where: u.user_id == ^id
    )
    |> Repo.one!()
  end

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id) do
    from(
      u in User,
      preload: [:settings, :badges, [badges_users: :badge]],
      where: u.user_id == ^id
    )
    |> Repo.one()
  end

  @doc """
  Gets the first user matching in either the username or the email column

  Returns nil if no user could be found

  ## Examples

      iex> get_user_user_by_username_or_email("Luke")
      %User{}

      iex> get_user_user_by_username_or_email("luke@example.org")
      %User{}

      iex> get_user_user_by_username_or_email("luke@aldebaran.gov")
      nil

  """
  def get_user_by_username_or_email(login) do
    from(
      user in User,
      preload: [:settings, :badges, [badges_users: :badge]],
      where:
        user.active == true and
          (fragment("lower(?)", user.email) == fragment("lower(?)", ^login) or
             fragment("lower(?)", user.username) == fragment("lower(?)", ^login))
    )
    |> Repo.one()
  end

  @doc """
  Gets a single user by a `reset_password_token`.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_reset_password_token!("aoeuaoeu")
      %User{}

      iex> get_user_by_reset_password_token!("nonexistant")
      ** (Ecto.NoResultsError)

  """
  def get_user_by_reset_password_token!(reset_token) do
    Repo.get_by!(User, reset_password_token: reset_token)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates the password of a user.

  ## Examples

      iex> update_user_password(user, %{password: new_value, password_confirmation: new_value})
      {:ok, %User{}}

      iex> update_user_password(user, %{password: new_value, password_confirmation: other_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Ecto.Changeset.change(%{reset_password_token: nil, reset_password_sent_at: nil})
    |> Repo.update()
  end

  @doc """
  Updates the `reset_password_token` of a user.

  ## Examples

      iex> update_user_password(user, %{reset_password_token: "111", reset_password_sent_at: Timex.now})
      {:ok, %User{}}

      iex> update_user_password(user, %{reset_password_token: nil, reset_password_sent_at: Timex.now})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_reset_password_token(%User{} = user, attrs) do
    user
    |> User.reset_password_token_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user password changes.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user_password(%User{} = user) do
    User.password_changeset(user, %{})
  end

  @doc """
  Registers a new user (creates an uncorfirmed new user)

  ## Examples

    iex> register_user(%{field: value})
    {:ok, %User{}}

    iex> register_user(%{field: bad_value})
    {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{active: true}
    |> User.register_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Confirms an unconfirmed user

  ## Examples

    iex> confirm_user("auaoeu")
    {:ok, %User{}}

    iex> confirm_user("nonexistant")
    {:error, nil}

  """
  def confirm_user(token) do
    case Repo.get_by(User, confirmation_token: token) do
      nil ->
        {:error, nil}

      user ->
        update_user(user, %{confirmed_at: Timex.now()})
    end
  end

  @doc """
  Generates a new `reset_password_token` for a user

  ## Examples

    iex> get_reset_password_token(%User{})
    %User{}

  """
  def get_reset_password_token(user) do
    token =
      :crypto.strong_rand_bytes(32)
      |> Base.encode64()
      |> binary_part(0, 32)

    {:ok, user} =
      update_user_reset_password_token(user, %{reset_password_token: token, reset_password_sent_at: Timex.now()})

    user
  end

  @doc """
  Returns a list of unique badges for a user

  ## Examples

    iex> unique_badges(user)
    [%Badge{}, ...]

  """
  def unique_badges(user) do
    user.badges_users
    |> Enum.reduce(%{}, fn bu, acc ->
         Map.update(
           acc,
           bu.badge_id,
           %{badge: bu.badge, created_at: bu.created_at, times: 1},
           &%{&1 | times: &1.times + 1}
         )
       end)
    |> Map.values()
    |> Enum.sort(&(&1[:times] >= &2[:times]))
  end

  @doc """
  Returns the configuration value for the directive specified by `config_name`; if the
  user is nil or has no settings of that name it returns the default value from
  the `Cforum.ConfigManager`

  ## Examples

    iex> conf(%User{}, "foo")
    "yes"

  """
  def conf(user, config_name)
  def conf(nil, name), do: Cforum.ConfigManager.defaults()[name]
  def conf(%User{settings: nil}, name), do: Cforum.ConfigManager.defaults()[name]

  def conf(%User{settings: settings}, name) do
    settings.options[name] || Cforum.ConfigManager.defaults()[name]
  end

  @doc """
  Authenticates a user specified by the login (email or username) and the password

  ## Examples

      iex> authenticate_user("luke", "foobar")
      {:ok, %User{}}

      iex> authenticate_user("luke", "wrong")
      {:error, %Ecto.Changeset{}}
  """
  def authenticate_user(login, password) do
    user = get_user_by_username_or_email(login)

    cond do
      user && Comeonin.Bcrypt.checkpw(password, user.encrypted_password) ->
        {:ok, user}

      user ->
        {:error, User.login_changeset(user, %{"login" => login, "password" => password})}

      true ->
        # just waste some time for timing sidechannel attacks
        Comeonin.Bcrypt.dummy_checkpw()
        {:error, User.login_changeset(%User{}, %{"login" => login, "password" => password})}
    end
  end

  @doc """
  Returns true if the user has a badge of the type specified by `badge`

  ## Examples
      iex> has_badge?(%User{}, "seo_profi")
      true

      iex> has_badge?(%User{}, "seo_profi")
      false
  """
  def has_badge?(user, badge) do
    Enum.find(user.badges, &(&1.badge_type == badge)) != nil
  end

  @doc """
  Returns true if the user is a moderator (in any forum)

  ## Examples
      iex> moderator?(%User{admin: true})
      true

      iex> moderator?(%User{})
      false
  """
  def moderator?(%User{admin: true}), do: true

  def moderator?(user) do
    pm_query =
      from(
        fpm in ForumGroupPermission,
        where:
          fpm.group_id in fragment("SELECT group_id FROM groups_users WHERE user_id = ?", ^user.user_id) and
            fpm.permission == ^ForumGroupPermission.moderate()
      )

    cond do
      has_badge?(user, Badge.moderator_tools()) ->
        true

      Repo.exists?(pm_query) ->
        true

      true ->
        false
    end
  end
end
