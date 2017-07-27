defmodule CforumWeb.Users.PasswordControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Accounts.Users

  test "renders password form for logged in users", %{conn: conn} do
    user = insert(:user)
    conn = login(conn, user)
    |> get(user_password_path(conn, :edit, user))

    assert html_response(conn, 200) =~ gettext("change password")
  end

  test "redirects for anonymous users", %{conn: conn} do
    user = insert(:user)
    conn = get(conn, user_password_path(conn, :edit, user))

    assert redirected_to(conn) == session_path(conn, :new)
    assert get_flash(conn, :error) == gettext("You don't have access to this page!")
  end

  test "changes password", %{conn: conn} do
    user = insert(:user, encrypted_password: "1234")
    conn = login(conn, user)
    |> put(user_password_path(conn, :update, user), user: %{password: "111", password_confirmation: "111"})

    u1 = Users.get_user!(user.user_id)

    assert redirected_to(conn) == user_path(conn, :show, user)
    assert get_flash(conn, :info) == gettext("Password updated successfully.")
    assert u1.encrypted_password != user.encrypted_password
  end

  test "does not change password when confirmation does not match", %{conn: conn} do
    user = insert(:user, encrypted_password: "1234")
    conn = login(conn, user)
    |> put(user_password_path(conn, :update, user), user: %{password: "111", password_confirmation: "222"})

    u1 = Users.get_user!(user.user_id)

    assert html_response(conn, 200) =~ gettext("change password")
    assert u1.encrypted_password == user.encrypted_password
  end
end
