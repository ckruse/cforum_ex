defmodule CforumWeb.User.UserControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Users
  alias Cforum.Users.User

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, Path.user_path(conn, :index))
    assert html_response(conn, 200) =~ gettext("Users")
  end

  test "shows chosen resource", %{conn: conn} do
    user = insert(:user)
    conn = get(conn, Path.user_path(conn, :show, user))
    assert html_response(conn, 200) =~ gettext("User %{username}", username: user.username)
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn -> get(conn, Path.user_path(conn, :show, %User{user_id: -1})) end)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user = insert(:user)

    conn =
      login(conn, user)
      |> get(Path.user_path(conn, :edit, user))

    assert html_response(conn, 200) =~ gettext("Edit profile: %{username}", username: user.username)
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = insert(:user)

    conn =
      login(conn, user)
      |> put(Path.user_path(conn, :update, user), user: %{username: "Luke"})

    assert redirected_to(conn) == Path.user_path(conn, :edit, user)
    user1 = Users.get_user!(user.user_id)
    assert %User{} = user1
    assert user1.username == "Luke"
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = insert(:user)

    conn =
      login(conn, user)
      |> put(Path.user_path(conn, :update, user), user: %{username: nil})

    assert html_response(conn, 200) =~ gettext("Edit profile: %{username}", username: user.username)
  end

  test "shows deletion confirmation dialogue", %{conn: conn} do
    user = insert(:user)

    conn =
      login(conn, user)
      |> get(Path.user_path(conn, :confirm_delete, user))

    assert html_response(conn, 200) =~ gettext("Delete user %{username}", username: user.username)
  end

  test "deletes chosen resource", %{conn: conn} do
    user = insert(:user)

    conn =
      login(conn, user)
      |> delete(Path.user_path(conn, :delete, user))

    assert %{success: 1, failure: 0, snoozed: 0} == Oban.drain_queue(queue: :background)
    assert redirected_to(conn) == Path.user_path(conn, :deletion_started)
    assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.user_id) end
  end
end
