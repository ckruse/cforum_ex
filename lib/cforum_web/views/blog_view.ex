defmodule CforumWeb.BlogView do
  use CforumWeb, :view

  alias Cforum.Helpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Paginator
  alias CforumWeb.Views.ViewHelpers.Feeds

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

  defp get_last_modified(nil), do: Timex.to_datetime({{1998, 7, 26}, {13, 19, 00}}, :local)
  defp get_last_modified(msg), do: msg.updated_at

  def render("index.atom", %{threads: threads, conn: conn}) do
    xml_threads = Enum.map(threads, &Feeds.atom_feed_thread(conn, &1))
    last_modified = get_last_modified(List.first(threads))

    conn
    |> Feeds.atom_feed_head(xml_threads, last_modified)
    |> XmlBuilder.generate()
  end

  def render("index.rss", %{threads: threads, conn: conn}) do
    xml_threads = Enum.map(threads, &Feeds.rss_feed_thread(conn, &1))

    conn
    |> Feeds.rss_feed_head(xml_threads)
    |> XmlBuilder.generate()
  end
end
