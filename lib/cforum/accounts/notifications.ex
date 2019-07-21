defmodule Cforum.Accounts.Notifications do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Accounts.Notification
  alias Cforum.Caching
  alias Cforum.Accounts.User

  def discard_unread_cache({:ok, notification}) do
    Caching.del(:cforum, "notifications/unread_count/#{notification.recipient_id}")
    {:ok, notification}
  end

  def discard_unread_cache(%User{} = user), do: Caching.del(:cforum, "notifications/unread_count/#{user.user_id}")
  def discard_unread_cache(val), do: val

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications(user, query_params \\ [order: nil, limit: nil]) do
    from(notification in Notification, where: notification.recipient_id == ^user.user_id)
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
  end

  def count_notifications(user, only_unread \\ false)

  def count_notifications(user, false) do
    from(notification in Notification, where: notification.recipient_id == ^user.user_id, select: count("*"))
    |> Repo.one()
  end

  def count_notifications(user, true) do
    Caching.fetch(:cforum, "notifications/unread_count/#{user.user_id}", fn ->
      from(notification in Notification,
        where: notification.recipient_id == ^user.user_id and notification.is_read == false,
        select: count("*")
      )
      |> Repo.one()
    end)
  end

  def list_unread_notifications(user, query_params \\ [order: nil, limit: nil]) do
    from(
      notification in Notification,
      where: notification.recipient_id == ^user.user_id and notification.is_read == false
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
    |> discard_unread_cache()
    |> notify_user()
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    ret =
      notification
      |> Notification.changeset(attrs)
      |> Repo.update()
      |> discard_unread_cache()

    notify_user(notification.recipient_id)

    ret
  end

  def delete_notification_for_object(user, oid, type) when is_list(oid) do
    {n, ret} =
      from(notification in Notification,
        where: notification.recipient_id == ^user.user_id and notification.oid in ^oid and notification.otype in ^type
      )
      |> Repo.delete_all()

    discard_unread_cache(user)
    if n > 0, do: notify_user(user)

    {n, ret}
  end

  def delete_notification_for_object(user, oid, type) do
    {n, ret} =
      from(notification in Notification,
        where: notification.recipient_id == ^user.user_id and notification.oid == ^oid and notification.otype in ^type
      )
      |> Repo.delete_all()

    discard_unread_cache(user)
    if n > 0, do: notify_user(user)

    {n, ret}
  end

  def mark_notifications_as_read(user, ids_or_nil, type \\ true)

  def mark_notifications_as_read(user, nil, type) do
    from(n in Notification, where: n.recipient_id == ^user.user_id)
    |> Repo.update_all(set: [is_read: type])

    discard_unread_cache(user)
    notify_user(user)
  end

  def mark_notifications_as_read(user, ids, type) do
    from(n in Notification, where: n.recipient_id == ^user.user_id and n.notification_id in ^ids)
    |> Repo.update_all(set: [is_read: type])

    discard_unread_cache(user)
    notify_user(user)
  end

  def delete_notifications(user, nil) do
    from(n in Notification, where: n.recipient_id == ^user.user_id)
    |> Repo.delete_all()

    discard_unread_cache(user)
    notify_user(user)
  end

  def delete_notifications(user, ids) do
    from(n in Notification, where: n.recipient_id == ^user.user_id and n.notification_id in ^ids)
    |> Repo.delete_all()

    discard_unread_cache(user)
    notify_user(user)
  end

  @doc """
  Deletes a Notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    ret =
      notification
      |> Repo.delete()
      |> discard_unread_cache()

    notify_user(notification.recipient_id)

    ret
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{source: %Notification{}}

  """
  def change_notification(%Notification{} = notification) do
    Notification.changeset(notification, %{})
  end

  def notify_user({:ok, %Notification{} = notification}) do
    notify_user(notification)
    {:ok, notification}
  end

  def notify_user(%Notification{} = notification) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      notification = Repo.preload(notification, [:recipient])
      unread_notifications = count_notifications(notification.recipient, true)

      CforumWeb.Endpoint.broadcast!("users:#{notification.recipient_id}", "new_notification", %{
        unread: unread_notifications,
        notification: notification
      })
    end)

    notification
  end

  def notify_user(id) when is_integer(id),
    do: notify_user(Cforum.Accounts.Users.get_user!(id))

  def notify_user(%User{} = user) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      unread_notifications = count_notifications(user, true)
      CforumWeb.Endpoint.broadcast!("users:#{user.user_id}", "notification_count", %{unread: unread_notifications})
    end)
  end

  def notify_user(retval), do: retval
end
