defmodule Cforum.Accounts.NotificationsTest do
  use Cforum.DataCase

  alias Cforum.Accounts.Notifications
  alias Cforum.Accounts.Notification

  test "list_notifications/2 returns all notifications" do
    notification = insert(:notification)
    notifications = Notifications.list_notifications(notification.recipient)
    assert length(notifications) == 1
    assert [%Notification{}] = notifications
    assert Enum.map(notifications, &(&1.notification_id)) == [notification.notification_id]
  end

  test "get_notification!/1 returns the notification with given id" do
    notification = insert(:notification)
    notification1 = Notifications.get_notification!(notification.notification_id)
    assert %Notification{} = notification1
    assert notification1.notification_id == notification.notification_id
  end

  test "create_notification/1 with valid data creates a notification" do
    user = insert(:user)
    params = params_for(:notification, recipient_id: user.user_id)
    assert {:ok, %Notification{} = notification} = Notifications.create_notification(params)
    assert notification.recipient_id == params[:recipient_id]
    assert notification.subject == params[:subject]
  end

  test "create_notification/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Notifications.create_notification(%{})
  end

  test "update_notification/2 with valid data updates the notification" do
    notification = insert(:notification)
    assert {:ok, notification1} = Notifications.update_notification(notification, %{subject: "Foo"})
    assert %Notification{} = notification1
    assert notification1.subject == "Foo"
  end

  test "update_notification/2 with invalid data returns error changeset" do
    notification = insert(:notification)
    assert {:error, %Ecto.Changeset{}} = Notifications.update_notification(notification, %{recipient_id: nil})
    notification1 = Notifications.get_notification!(notification.notification_id)
    assert %Notification{} = notification1
    assert notification1.recipient_id == notification.recipient_id
  end

  test "delete_notification/1 deletes the notification" do
    notification = insert(:notification)
    assert {:ok, %Notification{}} = Notifications.delete_notification(notification)
    assert_raise Ecto.NoResultsError, fn -> Notifications.get_notification!(notification.notification_id) end
  end

  test "change_notification/1 returns a notification changeset" do
    notification = insert(:notification)
    assert %Ecto.Changeset{} = Notifications.change_notification(notification)
  end
end
