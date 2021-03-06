defmodule CforumWeb.Users.PasswordControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Users

  test "renders send reset instructions form", %{conn: conn} do
    conn = get(conn, Path.password_path(conn, :new))
    assert html_response(conn, 200) =~ gettext("Send password reset instructions")
  end

  test "sets a reset password token", %{conn: conn} do
    user = insert(:user)
    conn = post(conn, Path.password_path(conn, :create), user: %{login: user.username})

    assert redirected_to(conn) == Path.root_path(conn, :index)
    assert get_flash(conn, :info) == gettext("The instructions how to reset your password have been sent.")
  end

  test "sends an instruction mail", %{conn: conn} do
    user = insert(:user)
    post(conn, Path.password_path(conn, :create), user: %{login: user.username})
    assert_enqueued(worker: Cforum.Jobs.UserMailerJob, args: %{"user_id" => user.user_id, "type" => "reset_password"})
  end

  test "renders reset instruction form when user could not be found", %{conn: conn} do
    conn = post(conn, Path.password_path(conn, :create), user: %{login: "Fizzban"})
    assert redirected_to(conn) == Path.root_path(conn, :index)
    assert get_flash(conn, :info) == gettext("The instructions how to reset your password have been sent.")
  end

  test "renders password form for logged in users", %{conn: conn} do
    user = insert(:user)

    conn =
      login(conn, user)
      |> get(Path.user_password_path(conn, :edit, user))

    assert html_response(conn, 200) =~ gettext("change password")
  end

  test "shows 403 for anonymous users", %{conn: conn} do
    user = insert(:user)
    assert_error_sent(403, fn -> get(conn, Path.user_password_path(conn, :edit, user)) end)
  end

  test "changes password", %{conn: conn} do
    user = insert(:user, encrypted_password: Bcrypt.hash_pwd_salt("1234"))

    conn =
      login(conn, user)
      |> put(Path.user_password_path(conn, :update, user),
        user: %{old_password: "1234", password: "111", password_confirmation: "111"}
      )

    u1 = Users.get_user!(user.user_id)

    assert redirected_to(conn) == Path.user_path(conn, :show, user)
    assert get_flash(conn, :info) == gettext("Password updated successfully.")
    assert u1.encrypted_password != user.encrypted_password
  end

  test "does not change password when confirmation does not match", %{conn: conn} do
    user = insert(:user, encrypted_password: Bcrypt.hash_pwd_salt("1234"))

    conn =
      login(conn, user)
      |> put(Path.user_password_path(conn, :update, user),
        user: %{old_password: "1234", password: "111", password_confirmation: "222"}
      )

    u1 = Users.get_user!(user.user_id)

    assert html_response(conn, 200) =~ gettext("change password")
    assert u1.encrypted_password == user.encrypted_password
  end

  test "does not change password when old password does not match", %{conn: conn} do
    user = insert(:user, encrypted_password: Bcrypt.hash_pwd_salt("1234"))

    conn =
      login(conn, user)
      |> put(Path.user_password_path(conn, :update, user),
        user: %{old_password: "12345", password: "111", password_confirmation: "111"}
      )

    u1 = Users.get_user!(user.user_id)

    assert html_response(conn, 200) =~ gettext("change password")
    assert u1.encrypted_password == user.encrypted_password
  end
end
