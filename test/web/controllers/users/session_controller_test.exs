defmodule Cforum.Users.SessionControllerTest do
  use Cforum.Web.ConnCase

  test "renders the login form for anonymous users", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ gettext("Login")
  end

  test "redirects for already logged-in users", %{conn: conn} do
    user = insert(:user)
    conn = login(conn, user)
    |> get(session_path(conn, :new))

    assert redirected_to(conn) == forum_path(conn, :index)
  end

  test "logs in successfully with right password", %{conn: conn} do
    user = build(:user)
    |> with_password("1234")
    |> insert

    conn = post conn, session_path(conn, :create, session: %{login: user.username,
                                                             password: "1234",
                                                             remember_me: "1"})

    assert redirected_to(conn) == forum_path(conn, :index)
    assert get_flash(conn, :info) == gettext("You logged in successfully")
  end

  test "shows error with wrong password", %{conn: conn} do
    user = build(:user)
    |> with_password("1234")
    |> insert

    conn = post conn, session_path(conn, :create, session: %{login: user.username,
                                                             password: "12345",
                                                             remember_me: "1"})

    assert html_response(conn, 200) =~ gettext("Login")
    assert get_flash(conn, :error) == gettext("Username or password wrong")
  end

  test "logs out the user", %{conn: conn} do
    user = build(:user)
    |> with_password("1234")
    |> insert

    conn = login(conn, user)
    |> delete(session_path(conn, :delete))

    assert redirected_to(conn) == forum_path(conn, :index)
    assert get_flash(conn, :info) == gettext("You logged out successfully")
  end

  test "confirms logout even when not logged in", %{conn: conn} do
    conn = delete(conn, session_path(conn, :delete))

    assert redirected_to(conn) == forum_path(conn, :index)
    assert get_flash(conn, :info) == gettext("You logged out successfully")
  end
end
