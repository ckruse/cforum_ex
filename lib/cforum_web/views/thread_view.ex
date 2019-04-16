defmodule CforumWeb.ThreadView do
  use CforumWeb, :view

  alias Cforum.Forums.{Thread, Threads}
  alias CforumWeb.Views.Helpers.Feeds

  defp archived_class(classes, %Thread{archived: true}), do: ["archived" | classes]
  defp archived_class(classes, _), do: classes

  defp sticky_class(classes, %Thread{sticky: true}), do: ["sticky" | classes]
  defp sticky_class(classes, _), do: classes

  defp no_archive_class(classes, %Thread{flags: %{"no-archive" => "yes"}}), do: ["no-archive" | classes]
  defp no_archive_class(classes, _), do: classes

  def thread_classes(thread) do
    thread.attribs[:classes]
    |> archived_class(thread)
    |> sticky_class(thread)
    |> no_archive_class(thread)
    |> Enum.join(" ")
  end

  def page_title(:index, assigns) do
    f = assigns[:current_forum]

    title = if f, do: f.name, else: gettext("all forums")
    gettext("overview – %{forum}", forum: title)
  end

  def page_title(:index_unanswered, assigns) do
    f = assigns[:current_forum]

    title = if f, do: f.name, else: gettext("all forums")
    gettext("unanswered threads – %{forum}", forum: title)
  end

  def page_title(action, _assigns) when action in [:new, :create], do: gettext("new thread")

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _assigns), do: "threads-index"
  def body_classes(:index, assigns), do: "threads forum-#{Path.forum_slug(assigns[:current_forum])}"

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

  def render("show.atom", %{conn: conn, thread: thread}) do
    xml_messages = Enum.map(thread.sorted_messages, &Feeds.atom_feed_message(conn, thread, &1))

    conn
    |> Feeds.atom_feed_head_for_thread(thread, xml_messages)
    |> XmlBuilder.generate()
  end

  def render("show.rss", %{conn: conn, thread: thread}) do
    xml_messages = Enum.map(thread.sorted_messages, &Feeds.rss_feed_message(conn, thread, &1))

    conn
    |> Feeds.rss_feed_head_for_thread(thread, xml_messages)
    |> XmlBuilder.generate()
  end

  def show_tree?(thread, view_all) do
    present?(thread.tree.messages) && (thread.attribs[:open_state] != "closed" || view_all)
  end
end
