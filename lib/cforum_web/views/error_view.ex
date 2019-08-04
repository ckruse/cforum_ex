defmodule CforumWeb.ErrorView do
  use CforumWeb, :view

  alias Cforum.Abilities

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def render("404.html", assigns) do
    ViewHelpers.l10n_render(
      CforumWeb.ErrorView,
      "error_404.html",
      Map.merge(
        assigns,
        %{layout: {CforumWeb.LayoutView, "error.html"}, title: gettext("page not found")}
      )
    )
  end

  def render("403.html", assigns) do
    ViewHelpers.l10n_render(
      CforumWeb.ErrorView,
      "error_403.html",
      Map.merge(
        assigns,
        %{layout: {CforumWeb.LayoutView, "error.html"}, title: gettext("access forbidden")}
      )
    )
  end

  def render("500.html", assigns) do
    ViewHelpers.l10n_render(
      CforumWeb.ErrorView,
      "error_500.html",
      Map.merge(
        assigns,
        %{layout: {CforumWeb.LayoutView, "error.html"}, title: gettext("internal server error")}
      )
    )
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render(
      "error_500.html",
      Map.merge(
        assigns,
        %{layout: {CforumWeb.LayoutView, "error.html"}, title: gettext("page not found")}
      )
    )
  end

  def original_path_w_view_all(conn) do
    url = URI.parse(maybe_set_forum(conn.request_path, conn.assigns[:current_forum]))

    query =
      url.query
      |> maybe_decode_query()
      |> Map.put("view_all", "yes")
      |> URI.encode_query()

    URI.to_string(%{url | query: query})
  end

  defp maybe_set_forum(path, forum),
    do: Regex.replace(~r/^\/all/, path, "/#{CforumWeb.Views.ViewHelpers.Path.forum_slug(forum)}")

  defp maybe_decode_query(nil), do: %{}
  defp maybe_decode_query(query), do: URI.decode_query(query)
end
