defmodule CforumWeb.CiteControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Cites

  @create_attrs %{
    archived: true,
    author: "some author",
    cite: "some cite",
    cite_date: ~N[2010-04-17 14:00:00.000000],
    creator: "some creator",
    old_id: 42,
    url: "some url"
  }
  @update_attrs %{
    archived: false,
    author: "some updated author",
    cite: "some updated cite",
    cite_date: ~N[2011-05-18 15:01:01.000000],
    creator: "some updated creator",
    old_id: 43,
    url: "some updated url"
  }
  @invalid_attrs %{archived: nil, author: nil, cite: nil, cite_date: nil, creator: nil, old_id: nil, url: nil}

  def fixture(:cite) do
    {:ok, cite} = Cites.create_cite(@create_attrs)
    cite
  end

  describe "index" do
    test "lists all cites", %{conn: conn} do
      conn = get(conn, cite_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Cites"
    end
  end

  describe "new cite" do
    test "renders form", %{conn: conn} do
      conn = get(conn, cite_path(conn, :new))
      assert html_response(conn, 200) =~ "New Cite"
    end
  end

  describe "create cite" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, cite_path(conn, :create), cite: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == cite_path(conn, :show, id)

      conn = get(conn, cite_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Cite"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, cite_path(conn, :create), cite: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Cite"
    end
  end

  describe "edit cite" do
    setup [:create_cite]

    test "renders form for editing chosen cite", %{conn: conn, cite: cite} do
      conn = get(conn, cite_path(conn, :edit, cite))
      assert html_response(conn, 200) =~ "Edit Cite"
    end
  end

  describe "update cite" do
    setup [:create_cite]

    test "redirects when data is valid", %{conn: conn, cite: cite} do
      conn = put(conn, cite_path(conn, :update, cite), cite: @update_attrs)
      assert redirected_to(conn) == cite_path(conn, :show, cite)

      conn = get(conn, cite_path(conn, :show, cite))
      assert html_response(conn, 200) =~ "some updated author"
    end

    test "renders errors when data is invalid", %{conn: conn, cite: cite} do
      conn = put(conn, cite_path(conn, :update, cite), cite: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Cite"
    end
  end

  describe "delete cite" do
    setup [:create_cite]

    test "deletes chosen cite", %{conn: conn, cite: cite} do
      conn = delete(conn, cite_path(conn, :delete, cite))
      assert redirected_to(conn) == cite_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, cite_path(conn, :show, cite))
      end)
    end
  end

  defp create_cite(_) do
    cite = fixture(:cite)
    {:ok, cite: cite}
  end
end
