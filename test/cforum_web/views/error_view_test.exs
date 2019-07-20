defmodule CforumWeb.ErrorViewTest do
  use CforumWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(CforumWeb.ErrorView, "404.html", [])
  end

  test "render 500.html" do
    assert render_to_string(CforumWeb.ErrorView, "500.html", [])
  end

  test "render any other" do
    assert render_to_string(CforumWeb.ErrorView, "505.html", [])
  end
end
