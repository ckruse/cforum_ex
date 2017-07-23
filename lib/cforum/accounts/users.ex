defmodule Cforum.Accounts.Users do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
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
    from(u in User,
      preload: [:settings, [badges_users: :badge]],
      where: u.user_id == ^id)
    |> Repo.one!
  end

  def get_user_by_username_or_email!(login) do
    from(user in User,
      preload: [:settings, [badges_users: :badge]],
      where: user.active == true and
             (fragment("lower(?)", user.email) == fragment("lower(?)", ^login) or
              fragment("lower(?)", user.username) == fragment("lower(?)", ^login)))
    |> Repo.one!
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
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

  def register_user(attrs) do
    %User{active: true}
    |> User.register_changeset(attrs)
    |> Repo.insert()
  end

  def confirm_user(token) do
    case Repo.get_by(User, confirmation_token: token) do
      nil ->
        {:error, nil}
      user ->
        update_user(user, %{confirmed_at: Timex.now})
    end
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

  def conf(user, name) do
    vals = case user.settings do
             nil ->
               %{}
             set ->
               set.options || %{}
           end

    vals[name] || Cforum.ConfigManager.defaults[name]
  end
end
