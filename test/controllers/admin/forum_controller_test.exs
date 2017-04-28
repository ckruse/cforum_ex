defmodule Cforum.Admin.ForumControllerTest do
  use Cforum.Web.ConnCase

  alias Cforum.Forum
  alias Cforum.User

  @valid_attrs %{description: "some content",
                 keywords: "some content",
                 name: "some content",
                 position: 42,
                 short_name: "some content",
                 slug: "foo",
                 standard_permission: "some content"}

  @invalid_attrs %{}

  setup do
    %User{
      user_id: 1,
      username: "admin",
      email: "admin@example.com",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("password"),
      admin: true
    } |> Repo.insert

    {:ok, user: Repo.get(User, 1)}
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    conn = login(conn, user)
    |> get(admin_forum_path(conn, :index))

    assert html_response(conn, 200) =~ gettext("Forums")
  end

  test "renders form for new resources", %{conn: conn, user: user} do
    conn = login(conn, user)
    |> get(admin_forum_path(conn, :new))

    assert html_response(conn, 200) =~ gettext("New forum")
  end

  test "creates resource and redirects when data is valid", %{conn: conn, user: user} do
    conn = login(conn, user)
    |> post(admin_forum_path(conn, :create), forum: @valid_attrs)

    assert redirected_to(conn) == admin_forum_path(conn, :index)
    assert Repo.get_by(Forum, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: user} do
    conn = login(conn, user)
    |> post(admin_forum_path(conn, :create), forum: @invalid_attrs)

    assert html_response(conn, 200) =~ gettext("New forum")
  end

  test "shows chosen resource", %{conn: conn, user: user} do
    forum = Repo.insert! %Forum{name: "foo", slug: "foo", short_name: "foo"}
    conn = login(conn, user)
    |> get(admin_forum_path(conn, :show, forum))

    assert html_response(conn, 200) =~ gettext("Show forum")
  end

  # TODO
  # test "renders page not found when id is nonexistent", %{conn: conn, user: user} do
  #   assert_error_sent 404, fn ->
  #     login(conn, user)
  #     |> get(admin_forum_path(conn, :show, "noneexistant"))
  #   end
  # end

  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    forum = Repo.insert! %Forum{name: "foo", slug: "foo", short_name: "foo"}
    conn = login(conn, user)
    |> get(admin_forum_path(conn, :edit, forum))

    assert html_response(conn, 200) =~ gettext("Edit forum")
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    forum = Repo.insert! %Forum{name: "foo", slug: "foo", short_name: "foo"}
    conn = login(conn, user)
    |> put(admin_forum_path(conn, :update, forum), forum: @valid_attrs)

    assert redirected_to(conn) == admin_forum_path(conn, :show, forum)
    assert Repo.get_by(Forum, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    forum = Repo.insert! %Forum{name: "foo", slug: "foo", short_name: "foo"}
    conn = login(conn, user)
    |> put(admin_forum_path(conn, :update, forum), forum: @invalid_attrs)

    assert html_response(conn, 200) =~ gettext("Edit forum")
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    forum = Repo.insert! %Forum{name: "foo", slug: "foo", short_name: "foo"}
    conn = login(conn, user)
    |> delete(admin_forum_path(conn, :delete, forum))

    assert redirected_to(conn) == admin_forum_path(conn, :index)
    refute Repo.get_by(Forum, slug: forum.slug)
  end
end
