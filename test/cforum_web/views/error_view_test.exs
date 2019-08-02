defmodule CforumWeb.ErrorViewTest do
  use CforumWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 403.html", %{conn: conn} do
    conn = put_private(conn, :phoenix_endpoint, CforumWeb.Endpoint)
    assert render_to_string(CforumWeb.ErrorView, "403.html", conn: conn, current_forum: nil)
  end

  test "renders 404.html", %{conn: conn} do
    conn = put_private(conn, :phoenix_endpoint, CforumWeb.Endpoint)
    assert render_to_string(CforumWeb.ErrorView, "404.html", conn: conn, current_forum: nil)
  end

  test "render 500.html", %{conn: conn} do
    conn = put_private(conn, :phoenix_endpoint, CforumWeb.Endpoint)
    assert render_to_string(CforumWeb.ErrorView, "500.html", conn: conn, current_forum: nil)
  end
end
