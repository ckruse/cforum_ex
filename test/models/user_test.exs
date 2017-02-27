defmodule Cforum.UserTest do
  use Cforum.ModelCase

  alias Cforum.User

  @valid_attrs %{active: true, admin: true, authentication_token: "some content", avatar_content_type: "some content", avatar_file_name: "some content", avatar_updated_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, confirmation_sent_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, confirmation_token: "some content", confirmed_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, current_sign_in_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, email: "some content", encrypted_password: "some content", last_sign_in_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, remember_created_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, reset_password_token: "some content", unconfirmed_email: "some content", username: "some content"}
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
