defmodule Cforum.NotificationTest do
  use Cforum.ModelCase

  alias Cforum.Notification

  @valid_attrs %{description: "some content", icon: "some content", is_read: true, oid: 42, otype: "some content", path: "some content", subject: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Notification.changeset(%Notification{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Notification.changeset(%Notification{}, @invalid_attrs)
    refute changeset.valid?
  end
end
