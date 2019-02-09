defmodule Cforum.Accounts.Badges do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.Query, warn: false
  import CforumWeb.Gettext
  alias Cforum.Repo

  alias Cforum.Accounts.Badge
  alias Cforum.Accounts.BadgeUser
  alias Cforum.Accounts.Notifications
  alias Cforum.System

  @doc """
  Returns the list of badges.

  ## Examples

      iex> list_badges()
      [%Badge{}, ...]

  """
  def list_badges(query_params \\ []) do
    query_params = Keyword.merge([order: nil, limit: nil, search: nil, preload: [badges_users: :user]], query_params)

    from(badge in Badge, preload: ^query_params[:preload])
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], asc: :order)
    |> Repo.all()
  end

  @doc """
  Counts the number of badges.

  ## Examples

      iex> count_badges()
      1

  """
  def count_badges() do
    from(
      badge in Badge,
      select: count("*")
    )
    |> Repo.one()
  end

  @doc """
  Gets a single badge.

  Raises `Ecto.NoResultsError` if the Badge does not exist.

  ## Examples

      iex> get_badge!(123)
      %Badge{}

      iex> get_badge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge!(id) do
    Repo.get!(Badge, id)
    |> Repo.preload(badges_users: :user)
  end

  def get_badge_by(clauses) do
    Repo.get_by(Badge, clauses)
  end

  @doc """
  Creates a badge.

  ## Examples

      iex> create_badge(%{field: value})
      {:ok, %Badge{}}

      iex> create_badge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge(current_user, attrs \\ %{}) do
    System.audited("create", current_user, fn ->
      %Badge{}
      |> Badge.changeset(attrs)
      |> Repo.insert()
    end)
  end

  @doc """
  Updates a badge.

  ## Examples

      iex> update_badge(badge, %{field: new_value})
      {:ok, %Badge{}}

      iex> update_badge(badge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge(current_user, %Badge{} = badge, attrs) do
    System.audited("update", current_user, fn ->
      badge
      |> Badge.changeset(attrs)
      |> Repo.update()
    end)
  end

  @doc """
  Deletes a Badge.

  ## Examples

      iex> delete_badge(badge)
      {:ok, %Badge{}}

      iex> delete_badge(badge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_badge(current_user, %Badge{} = badge) do
    System.audited("destroy", current_user, fn ->
      Repo.delete(badge)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge changes.

  ## Examples

      iex> change_badge(badge)
      %Ecto.Changeset{source: %Badge{}}

  """
  def change_badge(%Badge{} = badge) do
    Badge.changeset(badge, %{})
  end

  def unique_users(%Badge{} = badge) do
    badge.badges_users
    |> Enum.reduce(%{}, fn bu, acc ->
      Map.update(acc, bu.user_id, %{user: bu.user, times: 1, created_at: bu.created_at}, fn mp ->
        %{mp | times: mp[:times] + 1}
      end)
    end)
    |> Map.values()
  end

  def grant_badge(badge, user) do
    System.audited("badge-gained", user, fn ->
      %BadgeUser{}
      |> BadgeUser.changeset(%{user_id: user.user_id, badge_id: badge.badge_id})
      |> Repo.insert()
    end)
    |> notify_user(user, badge)
  end

  def notify_user({:ok, badge_user}, user, badge) do
    CforumWeb.Endpoint.broadcast!("users:#{user.user_id}", "new_badge_gained", %{badge: badge})

    Notifications.create_notification(%{
      recipient_id: user.user_id,
      subject: gettext("You have won the %{mtype} medal “%{name}”!", mtype: badge.badge_medal_type, name: badge.name),
      oid: badge.badge_id,
      otype: "badge",
      path: CforumWeb.Router.Helpers.badge_path(CforumWeb.Endpoint, :show, badge)
    })

    {:ok, badge_user}
  end

  def notify_user(val, _, _), do: val
end
