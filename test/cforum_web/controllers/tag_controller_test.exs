defmodule CforumWeb.TagControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Messages.Tag

  setup [:setup_tags]

  describe "index" do
    test "lists all entries on index", %{conn: conn, forum: forum} do
      tag = insert(:tag)
      tag1 = insert(:tag)
      thread = insert(:thread, forum: forum)
      insert(:message, thread: thread, forum: forum, tags: [tag])

      conn = get(conn, Path.tag_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("tags list", forum: forum.name)
      assert html_response(conn, 200) =~ tag.tag_name
      assert html_response(conn, 200) =~ tag1.tag_name
    end
  end

  describe "new" do
    test "renders form for new resources", %{conn: conn} do
      conn = get(conn, Path.tag_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("create new tag")
    end
  end

  describe "create" do
    test "creates resource and redirects when data is valid", %{conn: conn} do
      conn = post(conn, Path.tag_path(conn, :create), tag: params_for(:tag))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Path.tag_path(conn, :show, %Tag{slug: id})

      conn = get(conn, Path.tag_path(conn, :show, %Tag{slug: id}))
      assert html_response(conn, 200) =~ gettext("tag “%{tag}”", tag: conn.assigns[:tag].tag_name)
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Path.tag_path(conn, :create), tag: %{})
      assert html_response(conn, 200) =~ gettext("create new tag")
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn, forum: forum} do
      tag = insert(:tag)
      thread = insert(:thread, forum: forum)
      message = insert(:message, thread: thread, forum: forum, tags: [tag])

      conn = get(conn, Path.tag_path(conn, :show, tag))
      assert html_response(conn, 200) =~ gettext("tag “%{tag}”", tag: tag.tag_name)
      assert html_response(conn, 200) =~ message.subject
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent(404, fn -> get(conn, Path.tag_path(conn, :show, %Tag{slug: "-1"})) end)
    end
  end

  describe "edit" do
    test "renders form for editing chosen resource", %{conn: conn} do
      tag = insert(:tag)
      conn = get(conn, Path.tag_path(conn, :edit, tag))
      assert html_response(conn, 200) =~ gettext("edit tag “%{tag}”", tag: tag.tag_name)
    end
  end

  describe "update" do
    test "updates chosen resource and redirects when data is valid", %{conn: conn} do
      tag = insert(:tag, suggest: true)
      conn = put(conn, Path.tag_path(conn, :update, tag), tag: %{tag_name: "foo bar"})
      assert redirected_to(conn) == Path.tag_path(conn, :show, %Tag{slug: "foo-bar"})
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      tag = insert(:tag)
      conn = put(conn, Path.tag_path(conn, :update, tag), tag: %{tag_name: ""})
      assert html_response(conn, 200) =~ gettext("edit tag “%{tag}”", tag: tag.tag_name)
    end
  end

  describe "edit_merge" do
    test "renders form for merging two tags", %{conn: conn} do
      tag = insert(:tag)
      conn = get(conn, Path.tag_path(conn, :merge, tag))
      assert html_response(conn, 200) =~ gettext("merge tag %{tag}", tag: tag.tag_name)
    end
  end

  describe "merge" do
    test "redirects to tag after a merge", %{conn: conn} do
      tag = insert(:tag)
      tag1 = insert(:tag)
      conn = post(conn, Path.tag_path(conn, :merge, tag, existing_tag_id: tag1.tag_id))

      assert redirected_to(conn) == Path.tag_path(conn, :show, tag1)
      assert_error_sent(404, fn -> get(conn, Path.tag_path(conn, :show, tag)) end)
    end
  end

  describe "delete" do
    test "deletes chosen resource", %{conn: conn} do
      tag = insert(:tag)
      conn = delete(conn, Path.tag_path(conn, :delete, tag))
      assert redirected_to(conn) == Path.tag_path(conn, :index)
      assert_error_sent(404, fn -> get(conn, Path.tag_path(conn, :show, tag)) end)
    end
  end

  defp setup_tags(%{conn: conn}) do
    forum = insert(:public_forum)
    user = build(:user) |> as_admin |> insert
    {:ok, conn: login(conn, user), forum: forum, user: user}
  end
end
