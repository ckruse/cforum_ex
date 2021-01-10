defmodule CforumWeb.BlogView do
  use CforumWeb, :view

  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.Paginator
  alias CforumWeb.Views.ViewHelpers.Feeds

  def body_id(action, _assigns), do: "weblog-index-#{action}"
  def body_classes(action, assigns), do: "weblog forum-#{Path.forum_slug(assigns[:current_forum])} #{action}"

  defp get_last_modified(nil), do: Timex.to_datetime({{1998, 7, 26}, {13, 19, 00}}, :local)
  defp get_last_modified(msg), do: msg.updated_at

  def render("index.atom", %{threads: threads, conn: conn}) do
    xml_threads =
      for thread <- threads,
          do: Feeds.atom_feed_thread(conn, thread, &Path.blog_thread_url/3, &Path.blog_message_url/4)

    last_modified = get_last_modified(List.first(threads))

    conn
    |> Feeds.atom_feed_head(xml_threads, last_modified, Path.blog_url(conn), Path.blog_atom_url(conn))
    |> XmlBuilder.generate()
  end

  def render("index.rss", %{threads: threads, conn: conn}) do
    xml_threads = Enum.map(threads, &Feeds.rss_feed_thread(conn, &1))

    conn
    |> Feeds.rss_feed_head(xml_threads)
    |> XmlBuilder.generate()
  end
end
