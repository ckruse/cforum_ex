defmodule CforumWeb.ForumControllerTest do
  use CforumWeb.ConnCase

  test "lists forums on index", %{conn: conn} do
    conn = get(conn, root_path(conn, :index))
    assert html_response(conn, 200) =~ gettext("Forums")
  end
end
