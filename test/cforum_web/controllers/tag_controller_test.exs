defmodule CforumWeb.TagControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Forums.Tag

  setup [:setup_tags]

  test "lists all entries on index", %{conn: conn, forum: forum} do
    conn = get(conn, tag_path(conn, :index, forum))
    assert html_response(conn, 200) =~ gettext("tags for forum %{forum}", forum: forum.name)
  end

  test "lists all entries on index w/o forum", %{conn: conn} do
    conn = get(conn, tag_path(conn, :index, nil))
    assert html_response(conn, 200) =~ gettext("tags for all forum")
  end

  test "renders form for new resources", %{conn: conn, forum: forum} do
    conn = get(conn, tag_path(conn, :new, forum))
    assert html_response(conn, 200) =~ gettext("create new tag")
  end

  test "creates resource and redirects when data is valid", %{conn: conn, forum: forum} do
    conn = post(conn, tag_path(conn, :create, forum), tag: params_for(:tag))
    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == tag_path(conn, :show, forum, %Tag{slug: id})

    conn = get(conn, tag_path(conn, :show, forum, %Tag{slug: id}))

    assert html_response(conn, 200) =~
             gettext(
               "%{forum}: tag “%{tag}”",
               forum: conn.assigns[:current_forum].name,
               tag: conn.assigns[:tag].tag_name
             )
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, forum: forum} do
    conn = post(conn, tag_path(conn, :create, forum), tag: %{})
    assert html_response(conn, 200) =~ gettext("create new tag")
  end

  test "shows chosen resource", %{conn: conn, forum: forum} do
    tag = insert(:tag, forum: forum)
    conn = get(conn, tag_path(conn, :show, forum, tag))
    assert html_response(conn, 200) =~ gettext("%{forum}: tag “%{tag}”", forum: forum.name, tag: tag.tag_name)
  end

  test "renders page not found when id is nonexistent", %{conn: conn, forum: forum} do
    assert_error_sent(404, fn ->
      get(conn, tag_path(conn, :show, forum, %Tag{slug: "-1"}))
    end)
  end

  test "renders form for editing chosen resource", %{conn: conn, forum: forum} do
    tag = insert(:tag, forum: forum)
    conn = get(conn, tag_path(conn, :edit, forum, tag))
    assert html_response(conn, 200) =~ gettext("edit tag “%{tag}”", tag: tag.tag_name)
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, forum: forum} do
    tag = insert(:tag, suggest: true, forum: forum)
    conn = put(conn, tag_path(conn, :update, forum, tag), tag: %{tag_name: "foo bar"})
    assert redirected_to(conn) == tag_path(conn, :show, forum, %Tag{slug: "foo-bar"})
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, forum: forum} do
    tag = insert(:tag, forum: forum)
    conn = put(conn, tag_path(conn, :update, forum, tag), tag: %{tag_name: ""})
    assert html_response(conn, 200) =~ gettext("edit tag “%{tag}”", tag: tag.tag_name)
  end

  test "deletes chosen resource", %{conn: conn, forum: forum} do
    tag = insert(:tag, forum: forum)
    conn = delete(conn, tag_path(conn, :delete, forum, tag))
    assert redirected_to(conn) == tag_path(conn, :index, forum)
    assert_error_sent(404, fn -> get(conn, tag_path(conn, :show, forum, tag)) end)
  end

  defp setup_tags(%{conn: conn}) do
    forum = insert(:public_forum)
    user = build(:user) |> as_admin |> insert
    {:ok, conn: login(conn, user), forum: forum, user: user}
  end
end
