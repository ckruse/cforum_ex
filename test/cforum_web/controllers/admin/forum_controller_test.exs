defmodule CforumWeb.Admin.ForumControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Forums
  alias Cforum.Forums.Forum

  setup do
    {:ok, user: build(:user) |> as_admin |> insert}
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    forum = insert(:forum)

    conn =
      login(conn, user)
      |> get(Path.admin_forum_path(conn, :index))

    assert html_response(conn, 200) =~ gettext("administrate forums")
    assert html_response(conn, 200) =~ forum.name
  end

  test "renders form for new forum", %{conn: conn, user: user} do
    conn =
      login(conn, user)
      |> get(Path.admin_forum_path(conn, :new))

    assert html_response(conn, 200) =~ gettext("New Forum")
  end

  test "creates forum and redirects to show when data is valid", %{conn: conn, user: user} do
    conn =
      login(conn, user)
      |> post(Path.admin_forum_path(conn, :create), forum: params_for(:forum))

    assert %{id: id} = cf_redirected_params(conn)
    assert redirected_to(conn) == Path.admin_forum_path(conn, :edit, %Forum{slug: id})

    conn = get(conn, Path.admin_forum_path(conn, :edit, %Forum{slug: id}))
    forum = Forums.get_forum_by_slug!(id)
    assert html_response(conn, 200) =~ gettext("Show Forum „%{forum}“", forum: forum.name)
  end

  test "does not create forum and renders errors when data is invalid", %{conn: conn, user: user} do
    conn =
      login(conn, user)
      |> post(Path.admin_forum_path(conn, :create), forum: %{params_for(:forum) | slug: nil})

    assert html_response(conn, 200) =~ gettext("New Forum")
  end

  test "renders form for editing chosen forum", %{conn: conn, user: user} do
    forum = insert(:forum)

    conn =
      login(conn, user)
      |> get(Path.admin_forum_path(conn, :edit, forum))

    assert html_response(conn, 200) =~ gettext("Edit Forum „%{forum}“", forum: forum.name)
  end

  test "updates chosen forum and redirects when data is valid", %{conn: conn, user: user} do
    forum = insert(:forum)

    conn =
      login(conn, user)
      |> put(Path.admin_forum_path(conn, :update, forum), forum: %{name: "Foobar"})

    assert redirected_to(conn) == Path.admin_forum_path(conn, :edit, forum)

    conn = get(conn, Path.admin_forum_path(conn, :edit, forum))
    assert html_response(conn, 200) =~ "Foobar"
  end

  test "does not update chosen forum and renders errors when data is invalid", %{conn: conn, user: user} do
    forum = insert(:forum)

    conn =
      login(conn, user)
      |> put(Path.admin_forum_path(conn, :update, forum), forum: %{slug: nil})

    assert html_response(conn, 200) =~ gettext("Edit Forum „%{forum}“", forum: forum.name)
  end

  test "deletes chosen forum", %{conn: conn, user: user} do
    forum = insert(:forum)

    conn =
      login(conn, user)
      |> delete(Path.admin_forum_path(conn, :delete, forum))

    assert redirected_to(conn) == Path.admin_forum_path(conn, :index)
    assert_error_sent(404, fn -> get(conn, Path.admin_forum_path(conn, :edit, forum)) end)
  end

  describe "access rights" do
    test "anonymous isn't allowed to access", %{conn: conn} do
      assert_error_sent(403, fn -> get(conn, Path.admin_forum_path(conn, :index)) end)
    end

    test "non-admin user isn't allowed to access", %{conn: conn} do
      user = insert(:user)
      conn = login(conn, user)
      assert_error_sent(403, fn -> get(conn, Path.admin_forum_path(conn, :index)) end)
    end

    test "admin is allowed", %{conn: conn} do
      user = insert(:user, admin: true)

      conn =
        conn
        |> login(user)
        |> get(Path.admin_forum_path(conn, :index))

      assert html_response(conn, 200) =~ gettext("administrate forums")
    end
  end
end
