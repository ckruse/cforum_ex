defmodule Cforum.ForumControllerTest do
  use Cforum.ConnCase

  alias Cforum.Forum
  @valid_attrs %{description: "some content", keywords: "some content", name: "some content", position: 42, short_name: "some content", slug: "some content", standard_permission: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, forum_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing forums"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, forum_path(conn, :new)
    assert html_response(conn, 200) =~ "New forum"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, forum_path(conn, :create), forum: @valid_attrs
    assert redirected_to(conn) == forum_path(conn, :index)
    assert Repo.get_by(Forum, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, forum_path(conn, :create), forum: @invalid_attrs
    assert html_response(conn, 200) =~ "New forum"
  end

  test "shows chosen resource", %{conn: conn} do
    forum = Repo.insert! %Forum{}
    conn = get conn, forum_path(conn, :show, forum)
    assert html_response(conn, 200) =~ "Show forum"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, forum_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    forum = Repo.insert! %Forum{}
    conn = get conn, forum_path(conn, :edit, forum)
    assert html_response(conn, 200) =~ "Edit forum"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    forum = Repo.insert! %Forum{}
    conn = put conn, forum_path(conn, :update, forum), forum: @valid_attrs
    assert redirected_to(conn) == forum_path(conn, :show, forum)
    assert Repo.get_by(Forum, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    forum = Repo.insert! %Forum{}
    conn = put conn, forum_path(conn, :update, forum), forum: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit forum"
  end

  test "deletes chosen resource", %{conn: conn} do
    forum = Repo.insert! %Forum{}
    conn = delete conn, forum_path(conn, :delete, forum)
    assert redirected_to(conn) == forum_path(conn, :index)
    refute Repo.get(Forum, forum.id)
  end
end
