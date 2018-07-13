defmodule CforumWeb.Admin.RedirectionControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_login]

  describe "index" do
    test "lists all redirections", %{conn: conn} do
      conn = get(conn, admin_redirection_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("administrate redirections")
    end
  end

  describe "new redirection" do
    test "renders form", %{conn: conn} do
      conn = get(conn, admin_redirection_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new redirection")
    end
  end

  describe "create redirection" do
    test "redirects to edit when data is valid", %{conn: conn} do
      conn = post(conn, admin_redirection_path(conn, :create), redirection: params_for(:redirection))

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) == admin_redirection_path(conn, :edit, id)

      conn = get(conn, admin_redirection_path(conn, :edit, id))
      assert html_response(conn, 200) =~ gettext("edit redirection")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, admin_redirection_path(conn, :create), redirection: %{})
      assert html_response(conn, 200) =~ gettext("new redirection")
    end
  end

  describe "edit redirection" do
    setup [:create_redirection]

    test "renders form for editing chosen redirection", %{conn: conn, redirection: redirection} do
      conn = get(conn, admin_redirection_path(conn, :edit, redirection))
      assert html_response(conn, 200) =~ gettext("edit redirection")
    end
  end

  describe "update redirection" do
    setup [:create_redirection]

    test "redirects when data is valid", %{conn: conn, redirection: redirection} do
      conn = put(conn, admin_redirection_path(conn, :update, redirection), redirection: %{path: "/foo/bar"})
      assert redirected_to(conn) == admin_redirection_path(conn, :edit, redirection)

      conn = get(conn, admin_redirection_path(conn, :edit, redirection))
      assert html_response(conn, 200) =~ "/foo/bar"
    end

    test "renders errors when data is invalid", %{conn: conn, redirection: redirection} do
      conn = put(conn, admin_redirection_path(conn, :update, redirection), redirection: %{path: nil})
      assert html_response(conn, 200) =~ gettext("edit redirection")
    end
  end

  describe "delete redirection" do
    setup [:create_redirection]

    test "deletes chosen redirection", %{conn: conn, redirection: redirection} do
      conn = delete(conn, admin_redirection_path(conn, :delete, redirection))
      assert redirected_to(conn) == admin_redirection_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, admin_redirection_path(conn, :edit, redirection))
      end)
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
