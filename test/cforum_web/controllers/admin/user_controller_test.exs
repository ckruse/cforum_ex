defmodule CforumWeb.Admin.UserControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_login]

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, admin_user_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("administrate users")
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, admin_user_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new user")
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      params = params_for(:user)
      conn = post(conn, admin_user_path(conn, :create), user: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == admin_user_path(conn, :edit, id)

      conn = get(conn, admin_user_path(conn, :edit, id))
      assert html_response(conn, 200) =~ gettext("edit user „%{name}“", name: params[:username])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, admin_user_path(conn, :create), user: %{username: nil})
      assert html_response(conn, 200) =~ gettext("new user")
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, admin_user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ gettext("edit user „%{name}“", name: user.username)
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, admin_user_path(conn, :update, user), user: %{username: "Rebellion"})
      assert redirected_to(conn) == admin_user_path(conn, :edit, user)

      conn = get(conn, admin_user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Rebellion"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, admin_user_path(conn, :update, user), user: %{username: nil})
      assert html_response(conn, 200) =~ gettext("edit user „%{name}“", name: user.username)
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, admin_user_path(conn, :delete, user))
      assert redirected_to(conn) == admin_user_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, admin_user_path(conn, :edit, user))
      end)
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
