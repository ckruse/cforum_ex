defmodule CforumWeb.Admin.SearchSectionControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Search
  alias Cforum.Search.Section

  @create_attrs %{active_by_default: true, name: "some name", position: 42, section_type: "cites"}
  @update_attrs %{active_by_default: false, name: "some updated name", position: 43}
  @invalid_attrs %{active_by_default: nil, name: nil, position: nil}

  setup [:login_user]

  def fixture(:section) do
    {:ok, section} = Search.create_section(@create_attrs)
    section
  end

  describe "index" do
    test "lists all search_sections", %{conn: conn} do
      conn = get(conn, Path.admin_search_section_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("administrate search sections")
    end
  end

  describe "new section" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Path.admin_search_section_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new search section")
    end
  end

  describe "create section" do
    test "redirects to edit when data is valid", %{conn: conn} do
      conn = post(conn, Path.admin_search_section_path(conn, :create), section: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Path.admin_search_section_path(conn, :edit, %Section{search_section_id: id})

      conn = get(conn, Path.admin_search_section_path(conn, :edit, %Section{search_section_id: id}))
      assert html_response(conn, 200) =~ gettext("edit search section „%{name}“", name: "some name")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Path.admin_search_section_path(conn, :create), section: @invalid_attrs)
      assert html_response(conn, 200) =~ gettext("new search section")
    end
  end

  describe "edit section" do
    setup [:create_section]

    test "renders form for editing chosen section", %{conn: conn, section: section} do
      conn = get(conn, Path.admin_search_section_path(conn, :edit, section))
      assert html_response(conn, 200) =~ gettext("edit search section „%{name}“", name: section.name)
    end
  end

  describe "update section" do
    setup [:create_section]

    test "redirects when data is valid", %{conn: conn, section: section} do
      conn = put(conn, Path.admin_search_section_path(conn, :update, section), section: @update_attrs)
      assert redirected_to(conn) == Path.admin_search_section_path(conn, :edit, section)

      conn = get(conn, Path.admin_search_section_path(conn, :edit, section))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, section: section} do
      conn = put(conn, Path.admin_search_section_path(conn, :update, section), section: @invalid_attrs)
      assert html_response(conn, 200) =~ gettext("edit search section „%{name}“", name: section.name)
    end
  end

  describe "delete section" do
    setup [:create_section]

    test "deletes chosen section", %{conn: conn, section: section} do
      conn = delete(conn, Path.admin_search_section_path(conn, :delete, section))
      assert redirected_to(conn) == Path.admin_search_section_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Path.admin_search_section_path(conn, :edit, section))
      end)
    end
  end

  defp create_section(_) do
    section = fixture(:section)
    {:ok, section: section}
  end

  defp login_user(%{conn: conn}) do
    user = insert(:user, admin: true)
    {:ok, conn: login(conn, user), user: user}
  end
end
