defmodule Cforum.Accounts.Settings do
  @moduledoc """
  The boundary for the Accounts.Settings system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Accounts.Setting
  alias Cforum.Accounts.User
  alias Cforum.Forums.Forum

  @doc """
  Returns the list of settings for a user.

  ## Examples

      iex> list_settings(%User{})
      [%Setting{}, ...]

  """
  def list_settings(%User{} = user) do
    from(
      setting in Setting,
      where: setting.user_id == ^user.user_id
    )
    |> Repo.all()
  end

  @doc """
  Gets a single setting.

  Raises `Ecto.NoResultsError` if the Setting does not exist.

  ## Examples

      iex> get_setting!(123)
      %Setting{}

      iex> get_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_setting!(id) do
    Repo.get!(Setting, id)
  end

  @doc """
  Gets a setting object for a forum.

  Returns `nil` if there is no settings object for the given forum.

  ## Examples

      iex> get_setting_for_forum(%Forum{})
      %Setting{}

      iex> get_setting_for_forum(%Forum{})
      nil

  """
  def get_setting_for_forum(%Forum{} = forum) do
    from(
      setting in Setting,
      where: setting.forum_id == ^forum.forum_id
    )
    |> Repo.one()
  end

  @doc """
  Creates a setting.

  ## Examples

      iex> create_setting(%{field: value})
      {:ok, %Setting{}}

      iex> create_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_setting(attrs) do
    %Setting{}
    |> Setting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a setting.

  ## Examples

      iex> update_setting(setting, %{field: new_value})
      {:ok, %Setting{}}

      iex> update_setting(setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_setting(%Setting{} = setting, attrs) do
    setting
    |> Setting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Setting.

  ## Examples

      iex> delete_setting(setting)
      {:ok, %Setting{}}

      iex> delete_setting(setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_setting(%Setting{} = setting) do
    Repo.delete(setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking setting changes.

  ## Examples

      iex> change_setting(setting)
      %Ecto.Changeset{source: %Setting{}}

  """
  def change_setting(%Setting{} = setting) do
    Setting.changeset(setting, %{})
  end

  @doc """
  Loads the global settings, the settings for a given forum and the settings
  for a given user. Omits if one of them is missing.

  ## Examples

      iex> load_relevant_settings(nil, nil)
      [%Setting{}]

      iex> load_relevant_settings(%Forum{}, nil)
      [%Setting{}, %Setting{}]

      iex> load_relevant_settings(nil, %User{})
      [%Setting{}, %Setting{}]

      iex> load_relevant_settings(%Forum{}, %User{})
      [%Setting{}, %Setting{}, %Setting{}]
  """
  def load_relevant_settings(forum, user)

  def load_relevant_settings(nil, nil) do
    from(
      setting in Setting,
      where: is_nil(setting.forum_id) and is_nil(setting.user_id)
    )
    |> Repo.all()
  end

  def load_relevant_settings(%Forum{} = forum, nil) do
    from(
      setting in Setting,
      where:
        (is_nil(setting.forum_id) and is_nil(setting.user_id)) or
          (is_nil(setting.user_id) and setting.forum_id == ^forum.forum_id),
      order_by: fragment("? NULLS FIRST", setting.forum_id)
    )
    |> Repo.all()
  end

  def load_relevant_settings(nil, %User{} = user) do
    from(
      setting in Setting,
      where:
        (is_nil(setting.forum_id) and is_nil(setting.user_id)) or
          (is_nil(setting.forum_id) and setting.user_id == ^user.user_id),
      order_by: fragment("? NULLS FIRST", setting.user_id)
    )
    |> Repo.all()
  end

  def load_relevant_settings(%Forum{} = forum, %User{} = user) do
    from(
      setting in Setting,
      where:
        (is_nil(setting.forum_id) and is_nil(setting.user_id)) or
          (is_nil(setting.forum_id) and setting.user_id == ^user.user_id) or
          (is_nil(setting.user_id) and setting.forum_id == ^forum.forum_id),
      order_by: fragment("? NULLS FIRST, ? NULLS FIRST", setting.user_id, setting.forum_id)
    )
    |> Repo.all()
  end

  @doc """
  Looks up a configuration option in a settings struct; if missing it returns
  the default value from the `Cforum.ConfigManager`

  ## Examples

      iex> conf(%Setting{}, "foo")
      "bar"
  """
  def conf(setting, nam) do
    setting.options[nam] || Cforum.ConfigManager.defaults()[nam]
  end
end
