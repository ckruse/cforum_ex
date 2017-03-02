defmodule Cforum.UserControllerTest do
  use Cforum.ConnCase

  alias Cforum.User
  @valid_attrs %{active: true, admin: true, authentication_token: "some content", avatar_content_type: "some content", avatar_file_name: "some content", avatar_updated_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, confirmation_sent_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, confirmation_token: "some content", confirmed_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, current_sign_in_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, email: "some content", encrypted_password: "some content", last_sign_in_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, remember_created_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, reset_password_token: "some content", unconfirmed_email: "some content", username: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "deletes chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
