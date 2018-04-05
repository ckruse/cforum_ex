defmodule CforumWeb.CiteControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Cites

  @invalid_attrs %{archived: nil, author: nil, cite: nil, cite_date: nil, creator: nil, old_id: nil, url: nil}

  describe "index" do
    test "lists all cites", %{conn: conn} do
      cite = insert(:cite, archived: true)
      conn = get(conn, cite_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("cites")
      assert html_response(conn, 200) =~ cite.cite
    end
  end

  describe "new cite" do
    test "renders form", %{conn: conn} do
      conn = get(conn, cite_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("suggest new cite")
    end
  end

  describe "create cite" do
    test "redirects to show when data is valid", %{conn: conn} do
      attrs = params_for(:cite)
      conn = post(conn, cite_path(conn, :create), cite: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == cite_path(conn, :show, id)

      conn = get(conn, cite_path(conn, :show, id))
      assert html_response(conn, 200) =~ gettext("cite %{id}", id: id)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, cite_path(conn, :create), cite: @invalid_attrs)
      assert html_response(conn, 200) =~ gettext("suggest new cite")
    end
  end

  describe "edit cite" do
    setup [:create_cite]

    test "renders form for editing chosen cite", %{conn: conn, cite: cite, user: user} do
      conn =
        conn
        |> login(user)
        |> get(cite_path(conn, :edit, cite))

      assert html_response(conn, 200) =~ gettext("edit cite #%{id}", id: cite.cite_id)
    end
  end

  describe "update cite" do
    setup [:create_cite]

    test "redirects when data is valid", %{conn: conn, cite: cite, user: user} do
      conn =
        conn
        |> login(user)
        |> put(cite_path(conn, :update, cite), cite: %{author: "author foo bar"})

      assert redirected_to(conn) == cite_path(conn, :show, cite)

      conn = get(conn, cite_path(conn, :show, cite))
      assert html_response(conn, 200) =~ "author foo bar"
    end

    test "renders errors when data is invalid", %{conn: conn, cite: cite, user: user} do
      conn =
        conn
        |> login(user)
        |> put(cite_path(conn, :update, cite), cite: @invalid_attrs)

      assert html_response(conn, 200) =~ gettext("edit cite #%{id}", id: cite.cite_id)
    end
  end

  describe "delete cite" do
    setup [:create_cite]

    test "deletes chosen cite", %{conn: conn, cite: cite, user: user} do
      conn =
        conn
        |> login(user)
        |> delete(cite_path(conn, :delete, cite))

      assert redirected_to(conn) == cite_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, cite_path(conn, :show, cite))
      end)
    end
  end

  defp create_cite(_) do
    cite = insert(:cite)
    user = build(:user) |> as_admin |> insert
    {:ok, cite: cite, user: user}
  end
end
