defmodule CforumWeb.ThreadView do
  use CforumWeb, :view

  alias Cforum.Forums.Thread

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
    gettext("overview — %{forum}", forum: title)
  end

  def page_title(:index_unanswered, assigns) do
    f = assigns[:current_forum]

    title = if f, do: f.name, else: gettext("all forums")
    gettext("unanswered threads  — %{forum}", forum: title)
  end

  def page_title(action, _assigns) when action in [:new, :create], do: gettext("new thread")

  def page_heading(action, assigns) when action in [:new, :create], do: page_title(action, assigns)

  def body_id(:index, _assigns), do: "threads-index"
  def body_classes(:index, assigns), do: "threads forum-#{Path.forum_slug(assigns[:current_forum])}"

  alias CforumWeb.Views.Helpers.Feeds

  def render("index.atom", %{threads: threads, conn: conn}) do
    xml_threads = Enum.map(threads, &Feeds.atom_feed_thread(conn, &1))

    Feeds.atom_feed_head(conn, xml_threads, List.first(threads).created_at)
    |> XmlBuilder.generate()
  end

  def render("index.rss", %{threads: threads, conn: conn}) do
    xml_threads = Enum.map(threads, &Feeds.rss_feed_thread(conn, &1))

    Feeds.rss_feed_head(conn, xml_threads)
    |> XmlBuilder.generate()
  end

  def show_tree?(thread) do
    present?(thread.tree.messages) && thread.attribs[:open_state] != "closed"
  end
end
