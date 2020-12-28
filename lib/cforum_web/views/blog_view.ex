defmodule CforumWeb.BlogView do
  use CforumWeb, :view

  alias Cforum.Helpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.Views.ViewHelpers

  def page_title(:index, assigns),
    do: gettext("overview – %{forum}", forum: assigns[:current_forum].name)

  def body_id(action, _assigns), do: "weblog-index-#{action}"
  def body_classes(action, assigns), do: "weblog forum-#{Path.forum_slug(assigns[:current_forum])} #{action}"

  def excerpt(conn, message) do
    if Helpers.present?(message.excerpt),
      do: Cforum.MarkdownRenderer.to_html(message, conn, :excerpt),
      else: excerpt_from_content(conn, message)
  end

  defp excerpt_from_content(conn, message) do
    {:safe, content} = Cforum.MarkdownRenderer.to_html(message, conn)

    new_content =
      content
      |> String.replace(~r/<p>\s*<\/p>/s, "")
      |> String.replace(~r/(<\/p>|<!--more-->).*/s, "\\1")

    {:safe, new_content}
  end
end
