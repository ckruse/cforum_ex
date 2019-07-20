defmodule CforumWeb.Users.RegistrationControllerTest do
  use CforumWeb.ConnCase

  test "renders the registration form for anonymous users", %{conn: conn} do
    conn = get(conn, Path.registration_path(conn, :new))
    assert html_response(conn, 200) =~ gettext("Login")
  end

  test "shows a 403 for already logged-in users", %{conn: conn} do
    user = insert(:user)
    conn = get(login(conn, user), Path.registration_path(conn, :new))
    assert conn.status == 403
  end

  test "registers a new user", %{conn: conn} do
    conn =
      conn
      |> Plug.Test.put_req_cookie("cf_sess", "1")
      |> post(Path.registration_path(conn, :create),
        user: %{username: "foobar", email: "foo@example.org", password: "1234", password_confirmation: "1234"}
      )

    assert redirected_to(conn) == Path.root_path(conn, :index)

    assert get_flash(conn, :info) ==
             gettext("Account successfully created. Please follow the confirmation instructions we send you via mail.")
  end

  test "does not register a new user when logged in", %{conn: conn} do
    user = insert(:user)

    conn =
      post(
        login(conn, user),
        Path.registration_path(conn, :create),
        user: %{username: "foobar", email: "foo@example.org", password: "1234", password_confirmation: "1234"}
      )

    assert conn.status == 403
  end

  test "confirms a new user", %{conn: conn} do
    insert(:user, confirmation_token: "foobar")
    conn = get(conn, Path.registration_path(conn, :confirm, token: "foobar"))
    assert redirected_to(conn) == Path.root_path(conn, :index)
    assert get_flash(conn, :info) == gettext("Account successfully confirmed!")
  end

  test "shows an error on invalid confirmation token", %{conn: conn} do
    insert(:user, confirmation_token: "foobar")
    conn = get(conn, Path.registration_path(conn, :confirm, token: "foobarbaz"))
    assert redirected_to(conn) == Path.root_path(conn, :index)
    assert get_flash(conn, :error) == gettext("Oops, something went wrong!")
  end
end
