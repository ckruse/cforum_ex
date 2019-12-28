defmodule CforumWeb.Admin.UserControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Accounts.User

  describe "index" do
    setup [:setup_login]

    test "lists all users", %{conn: conn} do
      conn = get(conn, Path.admin_user_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("administrate users")
    end
  end

  describe "new user" do
    setup [:setup_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, Path.admin_user_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new user")
    end
  end

  describe "create user" do
    setup [:setup_login]

    test "redirects to show when data is valid", %{conn: conn} do
      params = params_for(:user)
      conn = post(conn, Path.admin_user_path(conn, :create), user: params)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) == Path.admin_user_path(conn, :edit, %User{user_id: id})

      conn = get(conn, Path.admin_user_path(conn, :edit, %User{user_id: id}))
      assert html_response(conn, 200) =~ gettext("edit user „%{name}“", name: params[:username])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Path.admin_user_path(conn, :create), user: %{username: nil})
      assert html_response(conn, 200) =~ gettext("new user")
    end
  end

  describe "edit user" do
    setup [:setup_login, :create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Path.admin_user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ gettext("edit user „%{name}“", name: user.username)
    end
  end

  describe "update user" do
    setup [:setup_login, :create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, Path.admin_user_path(conn, :update, user), user: %{username: "Rebellion"})
      assert redirected_to(conn) == Path.admin_user_path(conn, :edit, user)

      conn = get(conn, Path.admin_user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Rebellion"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Path.admin_user_path(conn, :update, user), user: %{username: nil})
      assert html_response(conn, 200) =~ gettext("edit user „%{name}“", name: user.username)
    end
  end

  describe "delete user" do
    setup [:setup_login, :create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Path.admin_user_path(conn, :delete, user))
      assert %{success: 1, failure: 0} == Oban.drain_queue(:background)
      assert redirected_to(conn) == Path.admin_user_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Path.admin_user_path(conn, :edit, user))
      end)
    end
  end

  describe "access rights" do
    test "anonymous isn't allowed to access", %{conn: conn} do
      assert_error_sent(403, fn -> get(conn, Path.admin_user_path(conn, :index)) end)
    end

    test "non-admin user isn't allowed to access", %{conn: conn} do
      user = insert(:user)
      conn = login(conn, user)
      assert_error_sent(403, fn -> get(conn, Path.admin_user_path(conn, :index)) end)
    end

    test "admin is allowed", %{conn: conn} do
      user = insert(:user, admin: true)

      conn =
        conn
        |> login(user)
        |> get(Path.admin_user_path(conn, :index))

      assert html_response(conn, 200) =~ gettext("administrate users")
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, user: user}
  end

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    {:ok, user: user, conn: login(conn, user)}
  end
end
