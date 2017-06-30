defmodule Cforum.UserTest do
  use Cforum.ModelCase

  alias Cforum.Accounts.User

  @valid_attrs %{username: "foo", email: "bar", active: true, admin: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
