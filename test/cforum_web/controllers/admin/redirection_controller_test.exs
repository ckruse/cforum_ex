defmodule CforumWeb.Admin.RedirectionControllerTest do
  use CforumWeb.ConnCase

  describe "index" do
    setup [:setup_login]

    test "lists all redirections", %{conn: conn} do
      conn = get(conn, Routes.admin_redirection_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("administrate redirections")
    end
  end

  describe "new redirection" do
    setup [:setup_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.admin_redirection_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new redirection")
    end
  end

  describe "create redirection" do
    setup [:setup_login]

    test "redirects to edit when data is valid", %{conn: conn} do
      conn = post(conn, Routes.admin_redirection_path(conn, :create), redirection: params_for(:redirection))

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_redirection_path(conn, :edit, id)

      conn = get(conn, Routes.admin_redirection_path(conn, :edit, id))
      assert html_response(conn, 200) =~ gettext("edit redirection")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_redirection_path(conn, :create), redirection: %{})
      assert html_response(conn, 200) =~ gettext("new redirection")
    end
  end

  describe "edit redirection" do
    setup [:setup_login, :create_redirection]

    test "renders form for editing chosen redirection", %{conn: conn, redirection: redirection} do
      conn = get(conn, Routes.admin_redirection_path(conn, :edit, redirection))
      assert html_response(conn, 200) =~ gettext("edit redirection")
    end
  end

  describe "update redirection" do
    setup [:setup_login, :create_redirection]

    test "redirects when data is valid", %{conn: conn, redirection: redirection} do
      conn = put(conn, Routes.admin_redirection_path(conn, :update, redirection), redirection: %{path: "/foo/bar"})
      assert redirected_to(conn) == Routes.admin_redirection_path(conn, :edit, redirection)

      conn = get(conn, Routes.admin_redirection_path(conn, :edit, redirection))
      assert html_response(conn, 200) =~ "/foo/bar"
    end

    test "renders errors when data is invalid", %{conn: conn, redirection: redirection} do
      conn = put(conn, Routes.admin_redirection_path(conn, :update, redirection), redirection: %{path: nil})
      assert html_response(conn, 200) =~ gettext("edit redirection")
    end
  end

  describe "delete redirection" do
    setup [:setup_login, :create_redirection]

    test "deletes chosen redirection", %{conn: conn, redirection: redirection} do
      conn = delete(conn, Routes.admin_redirection_path(conn, :delete, redirection))
      assert redirected_to(conn) == Routes.admin_redirection_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.admin_redirection_path(conn, :edit, redirection))
      end)
    end
  end

  describe "access rights" do
    test "anonymous isn't allowed to access", %{conn: conn} do
      assert_error_sent(403, fn -> get(conn, Routes.admin_redirection_path(conn, :index)) end)
    end

    test "non-admin user isn't allowed to access", %{conn: conn} do
      user = insert(:user)
      conn = login(conn, user)
      assert_error_sent(403, fn -> get(conn, Routes.admin_redirection_path(conn, :index)) end)
    end

    test "admin is allowed", %{conn: conn} do
      user = insert(:user, admin: true)

      conn =
        conn
        |> login(user)
        |> get(Routes.admin_redirection_path(conn, :index))

      assert html_response(conn, 200) =~ gettext("administrate redirections")
    end
  end

  defp create_redirection(_) do
    redirection = insert(:redirection)
    {:ok, redirection: redirection}
  end

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    {:ok, user: user, conn: login(conn, user)}
  end
end
