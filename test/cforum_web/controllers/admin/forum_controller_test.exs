defmodule CforumWeb.Admin.ForumControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Forums

  setup do
    {:ok, user: build(:user) |> as_admin |> insert}
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    forum = insert(:forum)
    conn = login(conn, user)
    |> get(admin_forum_path(conn, :index))

    assert html_response(conn, 200) =~ gettext("Forums")
    assert html_response(conn, 200) =~ forum.name
  end

  test "renders form for new forum", %{conn: conn, user: user} do
    conn = login(conn, user)
    |> get(admin_forum_path(conn, :new))
    assert html_response(conn, 200) =~ gettext("New Forum")
  end

  test "creates forum and redirects to show when data is valid", %{conn: conn, user: user} do
    conn = login(conn, user)
    |> post(admin_forum_path(conn, :create), forum: params_for(:forum))

    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == admin_forum_path(conn, :show, id)

    conn = get conn, admin_forum_path(conn, :show, id)
    forum = Forums.get_forum_by_slug!(id)
    assert html_response(conn, 200) =~ gettext("Show Forum „%{forum}“", forum: forum.name)
  end

  test "does not create forum and renders errors when data is invalid", %{conn: conn, user: user} do
    conn = login(conn, user)
    |> post(admin_forum_path(conn, :create), forum: %{params_for(:forum) | slug: nil})
    assert html_response(conn, 200) =~ gettext("New Forum")
  end

  test "renders form for editing chosen forum", %{conn: conn, user: user} do
    forum = insert(:forum)
    conn = login(conn, user)
    |> get(admin_forum_path(conn, :edit, forum))

    assert html_response(conn, 200) =~ gettext("Edit Forum „%{forum}“", forum: forum.name)
  end

  test "updates chosen forum and redirects when data is valid", %{conn: conn, user: user} do
    forum = insert(:forum)
    conn = login(conn, user)
    |> put(admin_forum_path(conn, :update, forum), forum: %{name: "Foobar"})

    assert redirected_to(conn) == admin_forum_path(conn, :show, forum)

    conn = get conn, admin_forum_path(conn, :show, forum)
    assert html_response(conn, 200) =~ "Foobar"
  end

  test "does not update chosen forum and renders errors when data is invalid", %{conn: conn, user: user} do
    forum = insert(:forum)
    conn = login(conn, user)
    |> put(admin_forum_path(conn, :update, forum), forum: %{slug: nil})
    assert html_response(conn, 200) =~ gettext("Edit Forum „%{forum}“", forum: forum.name)
  end

  test "deletes chosen forum", %{conn: conn, user: user} do
    forum = insert(:forum)
    conn = login(conn, user)
    |> delete(admin_forum_path(conn, :delete, forum))

    assert redirected_to(conn) == admin_forum_path(conn, :index)
    assert_error_sent 404, fn ->
      get conn, admin_forum_path(conn, :show, forum)
    end
  end
end
