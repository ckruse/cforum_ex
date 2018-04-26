defmodule CforumWeb.Users.SessionControllerTest do
  use CforumWeb.ConnCase

  test "renders the login form for anonymous users", %{conn: conn} do
    conn = get(conn, session_path(conn, :new))
    assert html_response(conn, 200) =~ gettext("Login")
  end

  test "sends 403 for already logged-in users", %{conn: conn} do
    user = insert(:user)

    conn =
      login(conn, user)
      |> get(session_path(conn, :new))

    assert response(conn, 403)
  end

  test "logs in successfully with right password", %{conn: conn} do
    user =
      build(:user)
      |> with_password("1234")
      |> insert

    conn = post(conn, session_path(conn, :create, user: %{login: user.username, password: "1234", remember_me: "true"}))

    assert redirected_to(conn) == root_path(conn, :index)
    assert get_flash(conn, :info) == gettext("You logged in successfully")
  end

  test "shows error with wrong password", %{conn: conn} do
    user =
      build(:user)
      |> with_password("1234")
      |> insert

    conn =
      post(conn, session_path(conn, :create, user: %{login: user.username, password: "12345", remember_me: "true"}))

    assert html_response(conn, 200) =~ gettext("Login")
    assert get_flash(conn, :error) == gettext("Username or password wrong")
  end

  test "shows 403 on create for already logged in users", %{conn: conn} do
    user =
      build(:user)
      |> with_password("1234")
      |> insert

    conn =
      login(conn, user)
      |> post(session_path(conn, :create, user: %{login: user.username, password: "12345", remember_me: "true"}))

    assert response(conn, 403)
    assert get_flash(conn, :error) == gettext("You don't have access to this page!")
  end

  test "logs out the user", %{conn: conn} do
    user =
      build(:user)
      |> with_password("1234")
      |> insert

    conn =
      login(conn, user)
      |> delete(session_path(conn, :delete))

    assert redirected_to(conn) == root_path(conn, :index)
    assert get_flash(conn, :info) == gettext("You logged out successfully")
  end

  test "deletes the remember_me token upon logout", %{conn: conn} do
    user =
      build(:user)
      |> with_password("1234")
      |> insert

    conn = post(conn, session_path(conn, :create, user: %{login: user.username, password: "1234", remember_me: "true"}))

    conn = delete(conn, session_path(conn, :delete))

    assert redirected_to(conn) == root_path(conn, :index)
    assert get_flash(conn, :info) == gettext("You logged out successfully")
    assert conn.cookies["remember_me"] == nil
  end

  test "shows 403 path when not logged in", %{conn: conn} do
    conn = delete(conn, session_path(conn, :delete))

    assert response(conn, 403)
    assert get_flash(conn, :error) == gettext("You have to be logged in to see this page!")
  end
end
