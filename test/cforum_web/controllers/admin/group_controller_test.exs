defmodule CforumWeb.Admin.GroupControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Accounts.Group

  describe "index" do
    setup [:setup_login]

    test "lists all groups", %{conn: conn} do
      conn = get(conn, Path.admin_group_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("administrate groups")
    end
  end

  describe "new group" do
    setup [:setup_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, Path.admin_group_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new group")
    end
  end

  describe "create group" do
    setup [:setup_login]

    test "redirects to show when data is valid", %{conn: conn} do
      params = params_for(:group)
      conn = post(conn, Path.admin_group_path(conn, :create), group: params)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) == Path.admin_group_path(conn, :edit, %Group{group_id: id})

      conn = get(conn, Path.admin_group_path(conn, :edit, %Group{group_id: id}))
      assert html_response(conn, 200) =~ gettext("edit group „%{name}“", name: params[:name])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Path.admin_group_path(conn, :create), group: %{name: nil})
      assert html_response(conn, 200) =~ gettext("new group")
    end
  end

  describe "edit group" do
    setup [:setup_login, :create_group]

    test "renders form for editing chosen group", %{conn: conn, group: group} do
      conn = get(conn, Path.admin_group_path(conn, :edit, group))
      assert html_response(conn, 200) =~ gettext("edit group „%{name}“", name: group.name)
    end
  end

  describe "update group" do
    setup [:setup_login, :create_group]

    test "redirects when data is valid", %{conn: conn, group: group} do
      conn = put(conn, Path.admin_group_path(conn, :update, group), group: %{name: "Rebellion"})
      assert redirected_to(conn) == Path.admin_group_path(conn, :edit, group)

      conn = get(conn, Path.admin_group_path(conn, :edit, group))
      assert html_response(conn, 200) =~ "Rebellion"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = put(conn, Path.admin_group_path(conn, :update, group), group: %{name: nil})
      assert html_response(conn, 200) =~ gettext("edit group „%{name}“", name: group.name)
    end
  end

  describe "delete group" do
    setup [:setup_login, :create_group]

    test "deletes chosen group", %{conn: conn, group: group} do
      conn = delete(conn, Path.admin_group_path(conn, :delete, group))
      assert redirected_to(conn) == Path.admin_group_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Path.admin_group_path(conn, :edit, group))
      end)
    end
  end

  describe "access rights" do
    test "anonymous isn't allowed to access", %{conn: conn} do
      conn = get(conn, Path.admin_group_path(conn, :index))
      assert conn.status == 403
    end

    test "non-admin user isn't allowed to access", %{conn: conn} do
      user = insert(:user)
      conn = login(conn, user)
      conn = get(conn, Path.admin_group_path(conn, :index))
      assert conn.status == 403
    end

    test "admin is allowed", %{conn: conn} do
      user = insert(:user, admin: true)

      conn =
        conn
        |> login(user)
        |> get(Path.admin_group_path(conn, :index))

      assert html_response(conn, 200) =~ gettext("administrate groups")
    end
  end

  defp create_group(_) do
    group = insert(:group)
    {:ok, group: group}
  end

  defp setup_login(%{conn: conn}) do
    user = build(:user) |> as_admin |> insert
    {:ok, user: user, conn: login(conn, user)}
  end
end
