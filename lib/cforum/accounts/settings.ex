defmodule Cforum.Accounts.Settings do
  @moduledoc """
  The boundary for the Accounts.Settings system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Accounts.Setting
  alias Cforum.System

  def discard_settings_cache({:ok, %{user_id: id} = settings}) when not is_nil(id) do
    Cforum.Caching.del(:cforum, "settings/user/#{id}")
    {:ok, settings}
  end

  def discard_settings_cache({:ok, %{forum_id: id} = settings}) when not is_nil(id) do
    Cforum.Caching.del(:cforum, "settings/forum/#{id}")
    {:ok, settings}
  end

  def discard_settings_cache({:ok, %{user_id: id} = user}) when not is_nil(id) do
    Cforum.Caching.del(:cforum, "settings/user/#{id}")
    {:ok, user}
  end

  def discard_settings_cache({:ok, settings}) do
    Cforum.Caching.del(:cforum, "settings/global")
    {:ok, settings}
  end

  def discard_settings_cache(val), do: val

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
  @spec get_setting_for_forum(%{forum_id: non_neg_integer()}) :: %Setting{} | nil
  def get_setting_for_forum(%{forum_id: id}) do
    Cforum.Caching.fetch(:cforum, "settings/forum/#{id}", fn ->
      from(setting in Setting, where: setting.forum_id == ^id)
      |> Repo.one()
    end)
  end

  @spec get_setting_for_user(%{user_id: non_neg_integer()}) :: %Setting{} | nil
  def get_setting_for_user(%{user_id: id}) do
    Cforum.Caching.fetch(:cforum, "settings/user/#{id}", fn ->
      from(setting in Setting, where: setting.user_id == ^id)
      |> Repo.one()
    end)
  end

  @doc """
  Gets the global setting object.

  Returns `nil` if there is no global settings object.

  ## Examples

  iex> get_global_setting()
  %Setting{}

  """
  @spec get_global_setting() :: %Setting{} | nil
  def get_global_setting() do
    Cforum.Caching.fetch(:cforum, "settings/global", fn ->
      from(setting in Setting, where: is_nil(setting.forum_id) and is_nil(setting.user_id))
      |> Repo.one()
    end)
  end

  @doc """
  Creates a setting.

  ## Examples

      iex> create_setting(%{field: value})
      {:ok, %Setting{}}

      iex> create_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_setting(current_user, attrs) do
    changeset = Setting.changeset(%Setting{}, attrs)

    if Ecto.Changeset.get_field(changeset, :user_id) == nil do
      System.audited("create", current_user, fn ->
        Repo.insert(changeset)
      end)
    else
      Repo.insert(changeset)
    end
    |> discard_settings_cache()
  end

  @doc """
  Updates a setting.

  ## Examples

      iex> update_setting(setting, %{field: new_value})
      {:ok, %Setting{}}

      iex> update_setting(setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_setting(current_user, %Setting{} = setting, attrs) do
    changeset = Setting.changeset(setting, attrs)

    if Ecto.Changeset.get_field(changeset, :user_id) == nil do
      System.audited("update", current_user, fn ->
        Repo.update(changeset)
      end)
    else
      Repo.update(changeset)
    end
    |> discard_settings_cache()
  end

  def update_options(current_user, setting, options) do
    if Cforum.Helpers.blank?(setting.setting_id),
      do: create_setting(current_user, %{"options" => options}),
      else: update_setting(current_user, setting, %{"options" => options})
  end

  @doc """
  Deletes a Setting.

  ## Examples

      iex> delete_setting(setting)
      {:ok, %Setting{}}

      iex> delete_setting(setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_setting(current_user, %Setting{} = setting) do
    if setting.user_id == nil do
      System.audited("destroy", current_user, fn ->
        Repo.delete(setting)
      end)
    else
      Repo.delete(setting)
    end
    |> discard_settings_cache()
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
    [get_global_setting()]
    |> Enum.reject(&is_nil(&1))
  end

  def load_relevant_settings(%{forum_id: _} = forum, nil) do
    [get_global_setting(), get_setting_for_forum(forum)]
    |> Enum.reject(&is_nil(&1))
  end

  def load_relevant_settings(nil, %{user_id: _} = user) do
    [get_global_setting(), get_setting_for_user(user)]
    |> Enum.reject(&is_nil(&1))
  end

  def load_relevant_settings(%{forum_id: _} = forum, %{user_id: _} = user) do
    [get_global_setting(), get_setting_for_forum(forum), get_setting_for_user(user)]
    |> Enum.reject(&is_nil(&1))
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
